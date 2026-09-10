import socket
import struct
import time
import random

DNS_SERVERS = {
    "Yandex": "77.88.8.8",
    "Yandex Safe": "77.88.8.88",
    "Google": "8.8.8.8",
    "Cloudflare": "1.1.1.1",
    "Quad9": "9.9.9.9",
    "OpenDNS": "208.67.222.222",
    "AdGuard": "94.140.14.14",
    "CleanBrowsing": "185.228.168.168",
    "Level3": "4.2.2.1",
    "Verisign": "64.6.64.6",
    "Google_2": "8.8.4.4",
}

# Домены для тестовых запросов
TEST_DOMAINS = ["google.com", "yandex.ru", "github.com"]
REQUESTS = 20


def build_dns_query(domain: str) -> bytes:
    """Создаёт DNS-запрос"""
    transaction_id = random.randint(0, 65535)

    # Заголовок DNS
    header = struct.pack(">HHHHHH",
                         transaction_id,  # ID
                         0x0100,  # Flags: стандартный запрос
                         1,  # Questions
                         0,  # Answers
                         0,  # Authority
                         0  # Additional
                         )

    # Формируем вопрос

    question = b""
    for part in domain.split("."):
        question += bytes([len(part)]) + part.encode()
    question += b"\x00"  # Конец домена
    question += struct.pack(">HH", 1, 1)  # Type A, Class IN

    return header + question


def dns_query(server_ip: str, domain: str, timeout: float = 2.0) -> float | None:
    """Отправляет DNS-запрос и возвращает время в мс"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(timeout)

        query = build_dns_query(domain)

        start = time.perf_counter()
        sock.sendto(query, (server_ip, 53))
        sock.recvfrom(512)
        end = time.perf_counter()

        sock.close()
        return (end - start) * 1000  # в миллисекундах
    except:
        return None


def test_dns(name: str, ip: str, requests: int = 3) -> dict | None:
    """Тестирует DNS-сервер несколько раз"""
    times = []

    for i in range(requests):
        domain = TEST_DOMAINS[i % len(TEST_DOMAINS)]
        result = dns_query(ip, domain)
        if result:
            times.append(result)

    if not times:
        return None

    return {
        "name": name,
        "ip": ip,
        "avg": sum(times) / len(times),
        "min": min(times),
        "max": max(times),
        "success": len(times),
        "total": requests
    }


def main():
    print("=" * 65)
    print("        DNS BENCHMARK - Реальные DNS-запросы")
    print("=" * 65)
    print(f"\nЗапросов на сервер: {REQUESTS}")
    print(f"Тестовые домены: {', '.join(TEST_DOMAINS)}")
    print("\nТестирование...\n")

    results = []

    for name, ip in DNS_SERVERS.items():
        print(f"  [{name:<18}] {ip:<18} ", end="", flush=True)

        result = test_dns(name, ip, REQUESTS)

        if result:
            results.append(result)
            print(f"✓ {result['avg']:>6.2f} мс (успешно: {result['success']}/{result['total']})")
        else:
            print("✗ Таймаут")

    # Сортировка
    results.sort(key=lambda x: x["avg"])

    # Результаты
    print("\n" + "=" * 70)
    print("                         РЕЙТИНГ DNS")
    print("=" * 70)
    print(f"{'#':<3} {'Сервер':<18} {'IP':<18} {'Avg (мс)':<10} {'Min':<10} {'Max':<10}")
    print("-" * 70)

    medals = {1: "🥇", 2: "🥈", 3: "🥉"}

    for i, r in enumerate(results, 1):
        medal = medals.get(i, "  ")
        print(f"{i:<3} {r['name']:<18} {r['ip']:<18} {r['avg']:<10.2f} {r['min']:<10.2f} {r['max']:<10.2f} {medal}")

    print("-" * 70)

    if results:
        best = results[0]
        second = results[1] if len(results) > 1 else None

        print(f"\n{'=' * 70}")
        print("                     РЕКОМЕНДАЦИЯ")
        print(f"{'=' * 70}")
        print(f"\n  ✅ Лучший DNS:     {best['name']} ({best['ip']})")
        print(f"     Среднее время:  {best['avg']:.2f} мс")

        if second:
            print(f"\n  📌 Резервный DNS:  {second['name']} ({second['ip']})")

        print(f"\n  📋 Настройки для сети:")
        print(f"     Предпочитаемый DNS:  {best['ip']}")
        if second:
            print(f"     Альтернативный DNS:  {second['ip']}")


if __name__ == "__main__":
    main()
    input("\n\nНажмите Enter для выхода...")
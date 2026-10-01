# РГР по теории вероятностей. Вариант 5

Отчёт оформлен в Typst: [REPORT.typ](REPORT.typ). В начале подключён существующий [титульный лист](artifacts/TITLE.typ).

- [Готовый PDF](REPORT.pdf).
- [Текст решения](report-body.typ).
- [Исходный код симуляции](artifacts/simulation.cpp).
- [Вывод выполненного запуска](artifacts/simulation-output.txt).

Сборка из этой папки:

```text
typst compile REPORT.typ REPORT.pdf
g++ -std=c++17 -O2 -Wall -Wextra -pedantic artifacts/simulation.cpp -o artifacts/simulation.exe
```

Запуск в PowerShell: `./artifacts/simulation.exe`.

Теоретическая вероятность: 12739 / 48546 ≈ 26,24%. В проведённой серии из 10 000 испытаний получено 2585 успехов (25,85%); абсолютное расхождение — 0,0039109. Повторный запуск даст новую случайную серию.

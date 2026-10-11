#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <cmath>
#include <iomanip>

using namespace std;

enum Card {
    A1, A2, B, C, D, X
};

void shuffleDeck(vector<int>& deck) {
    for (int i = static_cast<int>(deck.size()) - 1; i > 0; --i) {
        int j = rand() % (i + 1);

        int temp = deck[i];
        deck[i] = deck[j];
        deck[j] = temp;
    }
}

int drawTop(vector<int>& deck) {
    int card = deck.back();
    deck.pop_back();
    return card;
}

bool isA(int card) {
    return card == A1 || card == A2;
}

bool isKey(int card) {
    return card == A1 || card == A2 || card == B;
}

bool runExperiment() {
    vector<int> deck = {A1, A2, B, C, C, D, D};

    for (int i = 0; i < 26; ++i) {
        deck.push_back(X);
    }

    shuffleDeck(deck);

    vector<int> hand;
    vector<int> aside;

    while (static_cast<int>(hand.size()) < 5) {
        int card = drawTop(deck);

        if (card == C) aside.push_back(card);
        else hand.push_back(card);
    }

    vector<int> kept;

    for (int card : hand) {
        if (isKey(card)) kept.push_back(card);
        else aside.push_back(card);
    }

    hand = kept;

    while (static_cast<int>(hand.size()) < 5) {
        int card = drawTop(deck);

        if (card == C) aside.push_back(card);
        else hand.push_back(card);
    }

    for (int card : aside) deck.push_back(card);
    shuffleDeck(deck);

    int aCount = 0;
    int bCount = 0;
    int dCount = 0;

    bool haveA1 = false;

    for (int card : hand) {
        if (card == A1) {
            ++aCount;
            haveA1 = true;
        } else if (card == A2) {
            ++aCount;
        } else if (card == B) {
            ++bCount;
        } else if (card == D) {
            ++dCount;
        }
    }

    if (aCount == 2) return true;
    if (aCount == 1 && bCount == 1) return true;

    if (aCount == 0 && bCount == 1) {
        int first = drawTop(deck);

        if (isA(first)) return true;
        if (first == C) return false;

        int second = drawTop(deck);
        return isA(second);
    }

    if (aCount == 1 && bCount == 0) {
        int missingA = haveA1 ? A2 : A1;
        int first = drawTop(deck);

        if (first == B) return true;
        if (first == C) return false;
        if (first == missingA) return dCount > 0;

        int second = drawTop(deck);
        return second == B;
    }

    int first = drawTop(deck);
	
    if (first == C) return false;

    if (first == B) {
        int second = drawTop(deck);
        return isA(second);
    }

    if (isA(first)) {
        int second = drawTop(deck);
        return second == B;
    }

    return false;
}

int main() {
    srand(time(0));

    const int experiments = 10000;
    int successCount = 0;

    for (int i = 0; i < experiments; ++i) {
        if (runExperiment()) ++successCount;
    }

    double empirical = static_cast<double>(successCount) / experiments;
    double theoretical = 12739.0 / 48546.0;
    double difference = fabs(empirical - theoretical);

    cout << fixed << setprecision(7);
    cout << "Experiments: " << experiments << '\n';
    cout << "Successes: " << successCount << '\n';
    cout << "Empirical probability: " << empirical << '\n';
    cout << "Theoretical probability: " << theoretical << '\n';
    cout << "Absolute difference: " << difference << '\n';

    return 0;
}

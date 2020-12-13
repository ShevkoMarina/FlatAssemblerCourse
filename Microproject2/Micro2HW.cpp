#include <iostream>
#include <mutex>
#include <thread>
using namespace std;

class Semaphore {
public:
    void notify() {
        unique_lock<mutex> lock(mtx);
        count++;
        cv.notify_one();
    }

    void wait() {
        unique_lock<mutex> lock(mtx);
        while (count == 0) {
            cv.wait(lock);
        }
        count--;
    }

private:
    mutex mtx;
    condition_variable cv;
    int count = 0;
};

mutex waiter;
mutex cout_mutex;
Semaphore philo[5];
string philoStates[5] = { "thinking", "thinking", "thinking", "thinking", "thinking" };
string philoNames[5] = { "Aristotle", "Parmenides", "Plato", "Epicurus", "Socrates" };

void printInfo(int num, string message)
{
    cout_mutex.lock();
    if (message == " put forks") cout << "          ";
    cout << num << "-" << philoNames[num] << message << endl;
    cout_mutex.unlock();
}

void printStatus(int num)
{
    cout_mutex.lock();
    if (philoStates[num] == "thinking") cout << " ";
    if (philoStates[num] == "hungry")   cout << "   ";
    if (philoStates[num] == "eating")   cout << "       ";
    cout << num << "-" << philoNames[num] << " is " << philoStates[num] << endl;
    cout_mutex.unlock();
}

/// <summary>
/// �������� ��������� �������� �� ��� ����� ������ ��������. ���� ��, �� ��������� �������� ����� ����� � �� ���.
/// ���� ���� �� ���� �� ����� ������ (����� �������� ���), �� ������� �������� �� �������� "�������"
/// </summary>
/// <param name="phnum"></param>
void checkAvailability(int num)
{
    if (philoStates[num] == "hungry" && philoStates[(num + 4) % 5] != "eating" && philoStates[(num + 1) % 5] != "eating")
    {
        philoStates[num] = "eating";
        printStatus(num);
        philo[num].notify();
    }
}

/// <summary>
/// �������� ��������� ������� ��������� �����. ���� ��� ����, ������� �������� ����, ���� �� ��� 
/// - �������� � ������� "��������" � ����, ����� ��� ����� �����.
/// </summary>
/// <param name="phnum"></param>
void askForForks(int num)
{
    waiter.lock();
    philoStates[num] = "hungry";
    printStatus(num);
    checkAvailability(num);
    waiter.unlock();
    philo[num].wait(); // ���� ��������� ����� ����, �� �������� �������� ���������� �� 0 � �� ����� �� �����.
                       // ���� ����� ���� ������, �� ������� ����� ����� �� ��� ���, ���� �������� �� ��������, ��� ��� ����� ������������.
}

/// <summary>
/// ������� ������ ����� �� ���� � ����������� � �����������.
/// �������� ���������, ���� �� ������ � ����� �� ������������ ������� �������� ��, ��� ������� � ���� �����. 
/// ���� ����� ����, � ��� ���� ����� � ������ ������� �� ������, �� ����� �������� ���.
/// </summary>
/// <param name="phnum"></param>
void putForks(int num)
{
    waiter.lock();
    philoStates[num] = "thinking";
    printStatus(num);
    checkAvailability((num + 4) % 5);
    checkAvailability((num + 1) % 5);
    waiter.unlock();
}

/// <summary>
/// ������� �������� ��� ��������� - ������ �� 0 �� 5 ������
/// </summary>
void eating()
{
    srand(time(NULL));
    int timeToEat = rand() % 6;
    this_thread::sleep_for(chrono::seconds(timeToEat));
}

/// <summary>
/// �������� �������� ������ �� 0 �� 3 ������
/// </summary>
void thinking()
{
    srand(time(NULL));
    int timeToThink = rand() % 4;
    this_thread::sleep_for(chrono::seconds(timeToThink));
}

std::chrono::steady_clock::time_point t_start;
std::chrono::steady_clock::time_point t_end;


void dinning(int num)
{
    printStatus(num);
    while (t_end > chrono::high_resolution_clock::now())
    {
        thinking();                 // ������� ����� ����������
        printInfo(num, " asks waiter for forks");
        askForForks(num);           // ������� ������ ��������� ���� ��� �����. ���� ���� �� ���� �� ����� ������ 
                                    // �������� ������ �������� ���������, ���� ��� ������ �� �������� ����.
        eating();                   // ������� ���
        printInfo(num, " put forks");
        putForks(num);              // ������� ����������� ����. �������������� ����� �������� ��������� ����� ���������, ������ ����� �������.
    }
}

int main()
{
    // ����� �������� ����������� ������������ �������� �� ������
    cout << "Five philosofers are sitting at the table in the following sequence: " << endl;
    for (int i = 0; i < 5; i++)
    {
        cout << i << "-" << philoNames[i] << " ";
    }

    cout << endl << "--------------------------Waiter-Report-----------------------------" << endl;
    t_start = std::chrono::high_resolution_clock::now();
    t_end = t_start + 15s;

    // �������� ������� � ������ ������ �����
    thread philosofers[5];
    for (int i = 0; i < 5; i++)
    {
        philosofers[i] = thread(dinning, i);
    }

    // �������� ���������� ���� �������
    for (int i = 0; i < 5; i++)
    {
        philosofers[i].join();
    }
}
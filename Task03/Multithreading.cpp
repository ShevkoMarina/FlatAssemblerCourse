#include <iostream>
#include <vector>
#include <thread>
#include <mutex>

using namespace std;

mutex mtx;

int currentSector = 0;
int sectorsNum;
bool moneyFound = true;
int group = -1;

struct Sector
{
    int size = 0;
    bool withMoney = false;
};

Sector* sectors; // �������� �����

// �����- � ��������- ��������� �������
double uselessFunc(const int size)
{
    double d = 1;
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j)
            d += d * i * j  - d;
    }
    return d;
}

//������ ����� �������� �� ������������
int getNoOfSectors()
{
    cout << "Input number of search sectors on the area (0 < x < 1000): ";
    int num;
    cin >> num;
    while (num <= 0 or num > 1000)
    {
        printf("Incorrect input! Try again: ");
        cin >> num;
    }
    return num;
}

//������ ����� ����� �� ������������
int getNoOfGroups()
{
    // ���-�� ������������� �������, �������������� ��������
    unsigned int n = std::thread::hardware_concurrency();

    printf("Please input number of groups (0 < x <= %d): ", n);

    int num;
    cin >> num;
    while (num <= 0 or num > n)
    {
        printf("Incorrect input! Try again: ");
        cin >> num;
    }
    return num;
}

void* findMoney(int name)
{
    //���� ���� ���� �� �����
    while (moneyFound)
    {
        //������� ����� ������ �� ������ �������� � ������ ������� ������ Name
        //��������� ��� ������ ����� 
        mtx.lock();
        //������� ���� ������ i ������� ������ � ����������� �������
        int i = currentSector++;
        printf("---> Pirates group %d has got sector No.%d \n", name, i);
        mtx.unlock();
        //�������� �������� ������� ������� � ������� (���� ��� ���� ��� ���): 1 - ������������ 0 - ����������

        //�������� �������� - �������� ������ �����  
        auto t_start = std::chrono::high_resolution_clock::now();
        double d = uselessFunc(sectors[i].size);  // ��������� ������ ������� ������, ��������� �� ������� ���������� �������
        auto t_end = std::chrono::high_resolution_clock::now();
        double dt = std::chrono::duration<double, std::milli>(t_end - t_start).count();

        if (sectors[i].withMoney)
        {
            // ��������� ����� �� ����� � �������
            mtx.lock();
            printf("!!!! Pirates group %d has found money in the sector No.%d, Elapsed time %f mcs \n", name, i, dt);
            mtx.unlock();
            moneyFound = false;
            group = name;
        }
        else
        {
            mtx.lock();
            printf("<<<< Pirates group %d has NOT found money in the sector No.%d, Spent time %f mcs for %d size (%f)\n", name, i, dt, sectors[i].size, d);
            mtx.unlock();
        }

    }
    return nullptr;
}


int main()
{
    //�������� ���������� ��������
    sectorsNum = getNoOfSectors();

    //�������������� ������� �������
    sectors = new Sector[sectorsNum];

    // ���������� ������� ������� - � ������� ���� ������.
    for (int i = 0; i < sectorsNum; i++)
    {
        sectors[i] = Sector{ rand(), false };
    }

    // �������� �������� ������ � ������
    int sectorId = (double)rand() / RAND_MAX * sectorsNum;
    sectors[sectorId].withMoney = true;

    // ������� ���������� � ������ ���������� ������� � ������
    printf("INFO: Money has been located in the sector No.%d \n\n", sectorId);

    // ��������� ������ ������� ������������ ����������� ��������� �������
    int threadNumber = getNoOfGroups();
    vector<thread> thr(threadNumber);

    // �������� �������
    printf("-------------- Silver's report-------------------\n");
    auto t_start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < threadNumber; i++)
    {
        thr[i] = thread(findMoney, i);
    }

    for (int i = 0; i < threadNumber; i++)
    {
        thr[i].join();
    }

    auto t_end = std::chrono::high_resolution_clock::now();
    printf("\nRESULTS: Pirates group %d has found Money in the sector No.%d for %f ms \n", group, sectorId,
        std::chrono::duration<double, std::milli>(t_end - t_start).count());

    return 0;
}




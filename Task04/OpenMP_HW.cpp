#include <iostream>
#include <vector>
#include <omp.h>

using namespace std;

int currentSector = 0;
int sectorsNum;
bool moneyFound = false;
int group = -1;

struct Sector
{
    int size = 0;
    bool withMoney = false;
};

Sector* sectors; // портфель задач

// Время- и ресурсно- затратная функция
double uselessFunc(const int size)
{
    double d = 1;
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j)
            d += d * i * j - d;
    }
    return d;
}

//Запрос числа секторов от пользователя
int getNoOfSectors()
{
    cout << "Input number of search sectors on the area (0 < x < 1000): ";
    int num;
    cin >> num;
    while (num <= 0 or num > 1000)
    {
        // not a numeric character, probably
        if (cin.fail())
        {
            cin.clear();
            string c;
            cin >> c;
        }
        cout << "Invalid number, try again:";
        cin >> num;
    }
    return num;
}

//Запрос числа групп от пользователя
int getNoOfGroups()
{
    // Кол-во одновременных потоков, поддерживаемых системой
    unsigned int n = omp_get_max_threads();

    printf("Please input number of groups (0 < x <= %d): ", n);

    int num;
    cin >> num;
    while (num <= 0 or num > n)
    {
        // not a numeric character, probably
        if (cin.fail())
        {
            cin.clear();
            string c;
            cin >> c;
        }
        cout << "Invalid number, try again:";
        cin >> num;
    }
    return num;
}

int main()
{

    //получаем количество секторов
    int sectorsNum = getNoOfSectors();

    //инициалищируем секторы острова
    sectors = new Sector[sectorsNum];

    // генерируем сектора острова - у каждого свой размер.
    for (int i = 0; i < sectorsNum; i++)
    {
        sectors[i] = Sector{ rand(), false };
    }

    // рандомно выбираем сектор с кладом
    int sectorId = (double)rand() / RAND_MAX * sectorsNum;
    sectors[sectorId].withMoney = true;

    // выводим информацию о номере выбранного сектора с кладом
    printf("INFO: Money has been located in the sector No.%d \n\n", sectorId);


    double itime, ftime, exec_time;
    itime = omp_get_wtime();


    // поисковые группы пиратов симулируются количеством созданных потоков
    int threadNumber = getNoOfGroups();
    omp_set_num_threads(threadNumber);
    int sectorfound = -1;
    int groupfound = -1;

    #pragma omp parallel
    {
        int group = omp_get_thread_num();
        //ищем пока клад не найдн
        while (!moneyFound && currentSector < sectorsNum)
        {
            int i = 0;
            
            {
                // Свободная группа пиратов берет задачу из портфеля на обыск сектора
                // блокируем для других групп 
                #pragma omp critical 
                {
                    i = currentSector++;
                    printf("---> Pirates group %d has got sector No.%d \n", group, i);
                }

               
                // Имитируем временную задержку при обыске сектора
                double d = uselessFunc(sectors[i].size);  // нагружаем группу объемом работы, зависящим от размера поискового сектора

                if (sectors[i].withMoney)
                {
                    // блокируем поток на вывод в консоль
                    #pragma omp critical 
                    {
                        printf("!!!! Pirates group %d has found money in the sector No.%d \n", group, i);
                    }
                    moneyFound = true;
                    groupfound = group;
                    sectorfound = i;
                }
                else
                {
                    #pragma omp critical 
                    {
                        printf("   < Pirates group %d has NOT found money in the sector No.%d (%f) \n", group, i, d);
                    }
                }

            }
        }
    }

    ftime = omp_get_wtime();
    exec_time = ftime - itime;    
    printf("\nRESULTS: Pirates group %d has found Money in the sector No.%d \n", groupfound, sectorfound);
    printf("         CPU time by using of %d groups (cores) is %f sec\n", threadNumber, exec_time);

    return 0;
}




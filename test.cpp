#include <iostream>

extern "C" void input_number(int *address);

int main()
{
    int number = 0;
    input_number(&number);
    std::cout << "Number: " << number << std::endl;
    return 0;
}
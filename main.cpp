#include <iostream>

// Declare the assembly functions
extern "C" void input_number(int *address);
extern "C" void output_number(int number);

int main()
{
	int number = 0;
	std::cout << "Number: " << number << std::endl;
	input_number(&number); // Read a number from the user using assembly

	output_number(number); // Output the number using assembl
	return 0;
}

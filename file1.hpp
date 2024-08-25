#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <cctype>
#include <algorithm>

class File{
	// Vou usar eax como acumulador e ebx e ecx para outras coisas
	private:
		std::vector<int32_t> object;
		std::string output_filename;
		bool stop;
		int address;

		std::vector<int> constante;
		std::vector<int> variable;

	public:
		void ReadFile(std::string file);
		std::vector<std::string> Instructions();

		void Get_Const();
		void WriteFile();

		std::vector<std::string> Write_ADDSUB(int opc);
		std::vector<std::string> Write_LOADSTORE(int opc);
		std::vector<std::string> Write_COPY();
		std::vector<std::string> Write_STOP();

		std::vector<std::string> Write_Const();



};





enum opcodes{
	ADD = 1, SUB = 2, MUL = 3, DIV = 4, JMP = 5, JMPN = 6,
	JMPP = 7, JMPZ = 8, COPY = 9, LOAD = 10, STORE = 11,
	INPUT = 12, OUTPUT = 13, STOP = 14};
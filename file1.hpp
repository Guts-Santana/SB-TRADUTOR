#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

extern "C" void input_number(int *address);
extern "C" void output_number(int number);

class File {
  // Vou usar eax como acumulador e ebx e ecx para outras coisas
private:
  std::vector<int32_t> object;
  std::string output_filename;
  bool stop;
  int address;

  std::vector<int> constante;
  std::vector<uint> variable;
  std::vector<int> jmp_address;


public:
  void ReadFile(std::string file);

  void GetJumps();
  void Get_Const();
  void WriteFile();

  std::vector<std::string> Instructions();

  std::vector<std::string> Write_ADDSUB(int opc);
  std::vector<std::string> Write_MUL();
  std::vector<std::string> Write_DIV();
  std::vector<std::string> Write_JMP();
  std::vector<std::string> Write_LOADSTORE(int opc);
  std::vector<std::string> Write_COPY();
  std::vector<std::string> Write_STOP();

  std::vector<std::string> Write_Const();
  std::vector<std::string> Write_Variable();
  std::vector<std::string> Write_JMP_ADDRESS();

  // std::vector<std::string> Write_Input();
  // std::vector<std::string> Write_Output();
};

enum opcodes {
  ADD = 1,
  SUB = 2,
  MUL = 3,
  DIV = 4,
  JMP = 5,
  JMPN = 6,
  JMPP = 7,
  JMPZ = 8,
  COPY = 9,
  LOAD = 10,
  STORE = 11,
  INPUT = 12,
  OUTPUT = 13,
  STOP = 14
};

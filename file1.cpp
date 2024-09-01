#include "file1.hpp"

extern "C" void input_number(int *address);
extern "C" void output_number(int number);

void File::ReadFile(std::string filename)
{
  stop = 0;
  std::string line;
  std::string word;
  std::ifstream file(filename);
  if (!file.is_open())
  {
    throw std::invalid_argument("File not founded");
  }
  getline(file, line);
  std::istringstream iss(line);

  while (iss >> word)
  {
    object.push_back(std::stoi(word));
  }

  output_filename = filename.substr(0, filename.size() - 3) + "asm";
  // GetJumps();
}

void File::GetJumps()
{
  int size = 0;
  while (object[size] != STOP)
  {
    bool neww = true;
    if (object[size] == COPY)
    {
      size++;
    }

    else if (object[size] <= JMPZ && object[size] >= JMP)
    {
      for (int i = 0; i < jmp_address.size(); i++)
      {
        if (object[size + 1] == jmp_address[i])
        {
          neww = false;
          break;
        }
      }
      if (neww)
      {
        jmp_address.push_back(object[size + 1]);
      }
    }
    size = size + 2;
  }
  // for (int i = 0; i < jmp_address.size(); i++)
  // {
  // 	std::cout<< jmp_address[i] << " " << std::flush;
  // }
}

std::vector<std::string> File::Write_JMP_ADDRESS()
{
  std::vector<std::string> write;
  bool is_jump = false;
  for (int i = 0; i < jmp_address.size(); i++)
  {
    if (address == jmp_address[i])
    {
      is_jump = true;
      break;
    }
  }
  if (is_jump)
  {
    write.push_back("jmp");
    write.push_back(std::to_string(address));
    write.push_back(":");
    write.push_back("\n");
  }
  return write;
}

std::vector<std::string> File::Instructions()
{

  std::vector<std::string> command;

  switch (object[address])
  {
  case ADD:
  case SUB:
    command = Write_ADDSUB(object[address]);
    break;
  case MUL:
    command = Write_MUL();
    break;
  case DIV:
    command = Write_DIV();
    break;
  case JMP:
  case JMPN:
  case JMPP:
  case JMPZ:
    command = Write_JMP();
    break;
  case COPY:
    command = Write_COPY();
    break;
  case LOAD:
  case STORE:
    command = Write_LOADSTORE(object[address]);
    break;
  case STOP:
    command = Write_STOP();
    // stop = true;
    break;
  case INPUT:
    input_number(&object[address + 1]);
    break;
  case OUTPUT:
    output_number(object[address + 1]);
    break;
  default:
    break;
  }
  return command;
}

void File::Get_Const()
{
  while (address < object.size())
  {
    if (object[address] == 0)
    {
      variable.push_back(address);
    }
    else
    {

      constante.push_back(object[address]);
      constante.push_back(address);
    }
    address++;
  }
}

void File::WriteFile()
{
  std::vector<std::string> command;
  std::vector<std::string> is_jump;
  std::ofstream file(output_filename);
  address = 0;
  if (!file.is_open())
  {
    std::cerr << "Unable to open file for writing" << std::endl;
    return;
  }
  file << "section .text" << '\n';
  file << "	global _start" << '\n';
  file << "_start:" << '\n';
  while (!stop && (address < object.size()))
  {
    is_jump = Write_JMP_ADDRESS();
    for (const std::string &i : is_jump)
    {
      file << i;
    }

    command = Instructions();
    if (object[address] == COPY)
    {
      address = address + 3;
    }
    else if (object[address] == STOP)
    {
      address++;
    }
    else
    {
      address = address + 2;
    }
    for (const std::string &i : command)
    {
      file << i;
    }
  }

  Get_Const();
  command = Write_Const();
  for (const std::string &i : command)
  {
    file << i;
  }

  command = Write_Variable();
  for (const std::string &i : command)
  {
    file << i;
  }
}

std::vector<std::string> File::Write_ADDSUB(int opc)
{
  std::vector<std::string> command;
  std::string addr;
  if (opc == ADD)
  {
    command.push_back("	add ");
  }
  else
  {
    command.push_back("	sub ");
  }

  addr = "a" + std::to_string(object[address + 1]);
  command.push_back("eax, ");
  command.push_back("[");
  command.push_back(addr);
  command.push_back("]");
  command.push_back("\n");

  return command;
}

std::vector<std::string> File::Write_LOADSTORE(int opc)
{
  std::vector<std::string> command;
  std::string addr;

  command.push_back("	mov ");
  addr = "a" + std::to_string(object[address + 1]);
  if (opc == LOAD)
  {
    command.push_back("eax, ");
    command.push_back("[");
    command.push_back(addr);
    command.push_back("]");
    command.push_back("\n");
  }
  else
  {
    command.push_back("[");
    command.push_back(addr);
    command.push_back("], ");
    command.push_back("eax");
    command.push_back("\n");
  }
  return command;
}

std::vector<std::string> File::Write_COPY() // precisa de um push
{
  std::string addr;
  std::vector<std::string> command;

  command.push_back("	push eax");
  command.push_back("\n");

  addr = "a" + std::to_string(object[address + 1]);
  command.push_back("	mov eax, [");
  command.push_back(addr);
  command.push_back("]");
  command.push_back("\n");

  addr = "a" + std::to_string(object[address + 2]);
  command.push_back("	mov [");
  command.push_back(addr);
  command.push_back("], ");
  command.push_back("eax");
  command.push_back("\n");

  command.push_back("	pop eax");
  command.push_back("\n");

  return command;
}

std::vector<std::string> File::Write_STOP()
{
  stop = true;
  std::vector<std::string> command;

  command.push_back("	mov eax, 1");
  command.push_back("\n");
  command.push_back("	mov ebx, 0");
  command.push_back("\n");
  command.push_back("	int 80h");
  command.push_back("\n");

  return command;
}

std::vector<std::string> File::Write_JMP()
{
  std::vector<std::string> command;
  std::string addr;
  command.push_back("	cmp eax, 0");
  command.push_back("\n");
  switch (object[address])
  {
  case JMP:
    command.push_back("	jmp ");
    break;

  case JMPN:
    command.push_back("	jl ");
    break;

  case JMPP:
    command.push_back("	jg ");
    break;

  case JMPZ:
    command.push_back("	je ");
  default:
    break;
  }
  addr = "jmp" + std::to_string(object[address + 1]);
  command.push_back(addr);
  command.push_back("\n");

  return command;
}

std::vector<std::string> File::Write_MUL()
{
  std::vector<std::string> command;
  std::string addr;
  command.push_back("	imul eax, [");

  addr = "a" + std::to_string(object[address + 1]);
  command.push_back(addr);
  command.push_back("]");
  command.push_back("\n");

  return command;
}

std::vector<std::string> File::Write_DIV()
{
  std::vector<std::string> command;
  std::string addr;
  command.push_back("	push edx");
  command.push_back("\n");
  command.push_back("	push ebx");
  command.push_back("\n");

  addr = "a" + std::to_string(object[address + 1]);
  command.push_back("	mov ebx, [");
  command.push_back(addr);
  command.push_back("]");
  command.push_back("\n");
  command.push_back("	cdq");
  command.push_back("\n");
  command.push_back("	idiv ebx");

  command.push_back("\n");
  command.push_back("	pop ebx");
  command.push_back("\n");
  command.push_back("	pop edx");
  command.push_back("\n");
  return command;
}

std::vector<std::string> File::Write_Const()
{
  int i = 0;
  std::vector<std::string> command;
  std::string addr;

  command.push_back("section .data");
  command.push_back("\n");
  while (i < constante.size())
  {
    addr = "a" + std::to_string(constante[i + 1]);
    command.push_back(addr);
    command.push_back(" dd ");
    command.push_back(std::to_string(constante[i]));
    command.push_back("\n");
    i = i + 2;
  }

  return command;
}

std::vector<std::string> File::Write_Variable()
{
  int i = 0;
  std::vector<std::string> command;
  std::string addr;

  command.push_back("section .bss");
  command.push_back("\n");
  while (i < variable.size())
  {
    addr = "a" + std::to_string(variable[i]);
    command.push_back(addr);
    command.push_back(" resd ");
    command.push_back("1");
    command.push_back("\n");
    i++;
  }
  return command;
}

int main()
{
  File R;
  R.ReadFile("in_out.obj");
  R.WriteFile();

  return 0;
}

// 	std::vector<std::string> File::Write_Input(){}
//	std::vector<std::string> File::Write_Output(){}

#include "file1.hpp"

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
}

std::vector<std::string> File::Instructions(){
	switch (object[address])
	{
	case ADD:
	case SUB:
		Write_ADDSUB(object[address]);
		break;
	case DIV:
	case MUL:
		break;
	case JMP:
	case JMPN:
	case JMPP:
	case JMPZ:
		break;
	case COPY:
		Write_COPY();
		break;
	case LOAD:
	case STORE:
		Write_ADDSUB(object[address]);
		break;
	case INPUT:
		break;
	case OUTPUT:
		break;
	case STOP:
		stop = address;
		break;
	}
}

void File::Get_Const(){
	while (address < object.size())
	{
		if(object[address] == 0)
		{
			variable.push_back(address);
		}
		else
		{
			constante.push_back(address);
		}
		address++;
	}
}

void File::WriteFile(){
	std::vector<std::string> command;
	std::ofstream file(output_filename);
	address = 0;
    if (!file.is_open())
    {
        std::cerr << "Unable to open file for writing" << std::endl;
        return;
    }
	file << "section .text" << '\n';
	while (!stop)
	{
		command = Instructions();
		if (object[address] == COPY)
		{
			address = address + 3;
		}
		else if (object[address] == STOP)
		{
			address++;
		}
		else{
			address = address + 2;
		}
		for (const std::string &i : command)
		{
			file << i;
		}
	}

	Get_Const();
}

std::vector<std::string> File::Write_ADDSUB(int opc)
{
	std::vector<std::string> command;
	std::string addr;
	if( opc == ADD)
	{
		command.push_back("add ");
	}
	else
	{
		command.push_back("sub ");
	}

	addr = "a" + std::to_string(address+1);
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

	command.push_back("mov ");
	addr = "a" + std::to_string(address+1);
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

	command.push_back("push eax");
	command.push_back("\n");

	addr = "a" + std::to_string(address+1);
	command.push_back("mov eax, [");
	command.push_back(addr);
	command.push_back("]");
	command.push_back("\n");

	addr = "a" + std::to_string(address+2);
	command.push_back("mov [");
	command.push_back(addr);
	command.push_back("], ");
	command.push_back("eax");
	command.push_back("\n");

	command.push_back("pop eax");
	command.push_back("\n");

	return command;
}

std::vector<std::string> File::Write_STOP()
{
	stop = true;
	std::vector<std::string> command;
	command.push_back("mov eax, 1");
	command.push_back("\n");
	command.push_back("mov ebx, 0");
	command.push_back("\n");
	command.push_back("int 80h");
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
		addr = "a" + std::to_string(constante[i]);
		command.push_back(addr);
		command.push_back(" dd ");
		command.push_back(std::to_string(constante[i]));
		command.push_back("\n");
	}
}


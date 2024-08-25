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
		Get_ADDSUB(object[address]);
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
		break;
	case LOAD:
	case STORE:
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
	int i = stop + 1;
	while (i < object.size())
	{
		if(object[i] == 0)
		{
			variable.push_back(i);
		}
		else
		{
			constante.push_back(i);
		}
		i++;
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
	while (address < object.size())
	{
		if (stop == 0)
		{
			command = Instructions();
			for (const std::string &i : command)
			{
				file << i << ' ';
			}
		}
		else
		{
			Get_Const();
			break;
		}
	}
	
    file.close();
}

std::vector<std::string> File::Get_ADDSUB(int opc)
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
	command.push_back(" X ");	//To use in \n
	
	address = address + 2;
	return command;
}

std::vector<std::string> File::Get_LOADSTORE(int opc)
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
		command.push_back(" X ");		//To use in \n

	}
	else
	{
		command.push_back("[");
		command.push_back(addr);
		command.push_back("], ");
		command.push_back("eax");
		command.push_back(" X ");
	}
	address = address + 2;
	return command;
}

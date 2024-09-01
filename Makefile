# Variables
CXX = g++
NASM = nasm
CXXFLAGS = -m32 -c
LDFLAGS = -m32
ASMFLAGS = -f elf32
TARGET = main
OBJECTS = file1.o io.o

# Targets and rules
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $(TARGET)

main.o: file1.cpp
	$(CXX) $(CXXFLAGS) file1.cpp -o file1.o

io.o: io.asm
	$(NASM) $(ASMFLAGS) io.asm -o io.o

clean:
	rm -f $(OBJECTS) $(TARGET)

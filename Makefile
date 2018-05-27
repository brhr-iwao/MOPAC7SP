TARGET = mop7sp.exe

FC = gfortran

RM = rm

FFLAGS = -g -O2 -std=legacy -fno-automatic

SRC = $(wildcard *.f)
OBJ = $(SRC:.f=.o)

.SUFFIXES: f. .o
.f.o:
	$(FC) -c $(FFLAGS) $<


.PHONY: all
all: $(TARGET)

$(TARGET): $(OBJ)
	$(FC) -o $(TARGET) $^


.PHONY: clean
clean:
		-$(RM) $(TARGET)
		-$(RM) $(OBJ)
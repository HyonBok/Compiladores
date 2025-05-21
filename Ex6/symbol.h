#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 100

typedef enum {
    INT_VAR,
    FLOAT_VAR,
    CHAR_VAR,
    STRING_VAR,
    BOOL_VAR
} VarType;

typedef struct Temp {
    int index;
    float value;
    struct Temp *next;
} Temp;

typedef struct Symbol {
    char *name;
    int temp_index;
    VarType type;
    struct Symbol *next;
} Symbol;

typedef struct IntValue {
    char *name;
    int value;
    struct IntValue *next;
} IntValue;

typedef struct FloatValue {
    char *name;
    float value;
    struct FloatValue *next;
} FloatValue;

typedef struct BoolValue {
    char *name;
    int value;
    struct BoolValue *next;
} BoolValue;

// Tabelas globais - só devem ser **definidas** em um .c
extern Symbol *symbolTable[TABLE_SIZE];
extern IntValue *intTable[TABLE_SIZE];
extern FloatValue *floatTable[TABLE_SIZE];
extern BoolValue *boolTable[TABLE_SIZE];

// Funções utilitárias
unsigned int hash(const char *str);
void add_symbol(const char *name, VarType type);
void set_int_value(const char *name, int value);
void set_float_value(const char *name, float value);
void set_bool_value(const char *name, int value);
void print_symbols(void);
void print_values(void);
int get_int_value(const char *name);
float get_float_value(const char *name);
int get_bool_value(const char *name);
VarType get_variable_type(const char *name);

#endif // SYMBOL_H

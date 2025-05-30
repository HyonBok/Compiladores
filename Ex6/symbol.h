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

typedef struct Symbol {
    char *name;
    VarType type;
    struct Symbol *next;
} Symbol;

// Tabelas globais - só devem ser **definidas** em um .c
extern Symbol *symbolTable[TABLE_SIZE];

// Funções utilitárias
unsigned int hash(const char *str);
void add_symbol(const char *name, VarType type);
Symbol *get_symbol(const char *name);
char *add_temp(int value, int unique);

#endif // SYMBOL_H

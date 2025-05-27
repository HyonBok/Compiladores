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
    char* value;
    int unique;
} Temp;

typedef struct Campo {
    int inicio;
    int tamanho;
    int linha;
} Campo;

typedef struct Symbol {
    char *name;
    VarType type;
    int tempIndex;
    struct Symbol *next;
} Symbol;

// Tabelas globais - só devem ser **definidas** em um .c
extern Symbol *symbolTable[TABLE_SIZE];

// Funções utilitárias
void add_line();
int get_line();
unsigned int hash(const char *str);
void add_symbol(const char *name, VarType type);
Temp *add_temp(char *value, int dropIndex);
Campo *add_campo(int inicio, int tamanho);

#endif // SYMBOL_H

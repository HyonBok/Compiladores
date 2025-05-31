#include "symbol.h"

// Definições das tabelas globais
Symbol *symbolTable[TABLE_SIZE] = {0};

int global_index = 0;

// Função de hash simples
unsigned int hash(const char *str) {
    unsigned int hash = 0;
    while (*str) {
        hash = (hash * 31) + *str++;
    }
    return hash % TABLE_SIZE;
}

// Adiciona símbolo
void add_symbol(const char *name, VarType type) {
    unsigned int index = hash(name);
    Symbol *symbol = symbolTable[index];
    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            if (symbol->type != type) {
                fprintf(stderr, "Erro: Variável '%s' já existe com tipo diferente!\n", name);
                exit(EXIT_FAILURE);
            }
            return;
        }
        symbol = symbol->next;
    }
    Symbol *newSymbol = malloc(sizeof(Symbol));
    if (!newSymbol) {
      perror("malloc failed");
      exit(EXIT_FAILURE);
    }

    newSymbol->name = strdup(name);
    if (!newSymbol->name) {
      perror("strdup failed");
      exit(EXIT_FAILURE);
    }
    
    newSymbol->type = type;
    newSymbol->next = symbolTable[index];
    symbolTable[index] = newSymbol;
}

Symbol *get_symbol(const char *name) {
    unsigned int index = hash(name);
    Symbol *symbol = symbolTable[index];
    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            return symbol;
        }
        symbol = symbol->next;
    }
    return NULL; // Não encontrado
}

// Adiciona temporário
Temp *add_temp(int value, int unique, VarType type) {
    Temp *temp = malloc(sizeof(Temp));
    if (!temp) {
      perror("malloc failed");
      exit(EXIT_FAILURE);
    }
    temp->value = malloc(20 * sizeof(char));
    if (!temp->value) {
        perror("malloc failed");
        exit(EXIT_FAILURE);
    }

    if(unique) {
        snprintf(temp->value, 20, "%d", value);
    }
    else{
        snprintf(temp->value, 20, "t%d", global_index);
        global_index++;
    }

    temp->type = type;

    return temp;
}

const char* var_type_to_string(VarType type) {
    switch (type) {
        case INT_VAR: return "int";
        case FLOAT_VAR: return "float";
        case BOOL_VAR: return "bool";
        default: return "unknown";
    }
}
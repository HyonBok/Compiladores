#include "symbol.h"

// Definições das tabelas globais
Symbol *symbolTable[TABLE_SIZE] = {0};
IntValue *intTable[TABLE_SIZE] = {0};
FloatValue *floatTable[TABLE_SIZE] = {0};
BoolValue *boolTable[TABLE_SIZE] = {0};

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

    newSymbol->name = strdup(name);
    newSymbol->type = type;
    newSymbol->next = symbolTable[index];
    symbolTable[index] = newSymbol;
}

// Adiciona valor inteiro
void set_int_value(const char *name, int value) {
    unsigned int index = hash(name);
    //add_symbol(name, INT_VAR);
    IntValue *val = intTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            val->value = value;
            return;
        }
        val = val->next;
    }
    IntValue *newValue = malloc(sizeof(IntValue));
    newValue->name = strdup(name);
    newValue->value = value;
    newValue->next = intTable[index];
    intTable[index] = newValue;
}

// Adiciona valor float
void set_float_value(const char *name, float value) {
    //add_symbol(name, FLOAT_VAR);
    unsigned int index = hash(name);
    FloatValue *val = floatTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            val->value = value;
            return;
        }
        val = val->next;
    }
    FloatValue *newValue = malloc(sizeof(FloatValue));
    newValue->name = strdup(name);
    newValue->value = value;
    newValue->next = floatTable[index];
    floatTable[index] = newValue;
}

// Adiciona valor booleano
void set_bool_value(const char *name, int value) {
    //add_symbol(name, BOOL_VAR);
    unsigned int index = hash(name);
    BoolValue *val = boolTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            val->value = value;
            return;
        }
        val = val->next;
    }
    BoolValue *newValue = malloc(sizeof(BoolValue));
    newValue->name = strdup(name);
    newValue->value = value;
    newValue->next = boolTable[index];
    boolTable[index] = newValue;
}

// Recupera valor inteiro
int get_int_value(const char *name) {
    unsigned int index = hash(name);
    IntValue *val = intTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            return val->value;
        }
        val = val->next;
    }
    fprintf(stderr, "Erro: Variável '%s' não encontrada na tabela de inteiros!\n", name);
    exit(EXIT_FAILURE);
}

// Recupera valor float
float get_float_value(const char *name) {
    unsigned int index = hash(name);
    FloatValue *val = floatTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            return val->value;
        }
        val = val->next;
    }
    fprintf(stderr, "Erro: Variável '%s' não encontrada na tabela de floats!\n", name);
    exit(EXIT_FAILURE);
}

// Recupera valor booleano
int get_bool_value(const char *name) {
    unsigned int index = hash(name);
    BoolValue *val = boolTable[index];
    while (val) {
        if (strcmp(val->name, name) == 0) {
            return val->value;
        }
        val = val->next;
    }
    fprintf(stderr, "Erro: Variável '%s' não encontrada na tabela de booleanos!\n", name);
    exit(EXIT_FAILURE);
}

// Recupera tipo da variável
VarType get_variable_type(const char *name) {
    unsigned int index = hash(name);
    Symbol *symbol = symbolTable[index];
    while (symbol) {
        if (strcmp(symbol->name, name) == 0) {
            return symbol->type;
        }
        symbol = symbol->next;
    }
    fprintf(stderr, "Erro: Variável '%s' não encontrada na tabela de símbolos!\n", name);
    exit(EXIT_FAILURE);
}

// Impressão das tabelas
void print_symbols(void) {
    printf("Tabela de Símbolos:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        Symbol *symbol = symbolTable[i];
        while (symbol) {
            printf("[%s - %d] -> ", symbol->name, symbol->type);
            symbol = symbol->next;
        }
    }
    printf("\n");
}

void print_values(void) {
    printf("Tabela de Inteiros:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        IntValue *val = intTable[i];
        while (val) {
            printf("[%s = %d] -> ", val->name, val->value);
            val = val->next;
        }
    }
    printf("\n");

    printf("Tabela de Floats:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        FloatValue *val = floatTable[i];
        while (val) {
            printf("[%s = %.2f] -> ", val->name, val->value);
            val = val->next;
        }
    }
    printf("\n");

    printf("Tabela de Booleanos:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        BoolValue *val = boolTable[i];
        while (val) {
            printf("[%s = %s] -> ", val->name, val->value ? "true" : "false");
            val = val->next;
        }
    }
    printf("\n");
}

#include "symbol.h"

// Definições das tabelas globais
Symbol *symbolTable[TABLE_SIZE] = {0};
Temp *tempTable[TABLE_SIZE] = {0};
IntValue *intTable[TABLE_SIZE] = {0};
FloatValue *floatTable[TABLE_SIZE] = {0};
BoolValue *boolTable[TABLE_SIZE] = {0};

int global_index = 1;
int global_line = 1;

void add_line() {
    global_line++;
}

int get_line() {
    return global_line;
}

// Função de hash simples
unsigned int hash(const char *str) {
    unsigned int hash = 0;
    while (*str) {
        hash = (hash * 31) + *str++;
    }
    return hash % TABLE_SIZE;
}

// Adiciona símbolo
void add_symbol(const char *name, VarType type, int tempIndex) {
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
    newSymbol->tempIndex = tempIndex;
    newSymbol->next = symbolTable[index];
    symbolTable[index] = newSymbol;
}

// Adiciona temporário
Temp *add_temp(int value, int unique) {
    Temp *temp = malloc(sizeof(Temp));
    if (!temp) {
      perror("malloc failed");
      exit(EXIT_FAILURE);
    }
    // Necessário apenas para os uniques
    temp->value = value;
    temp->index = global_index;
    temp->unique = unique;
    tempTable[global_index] = temp;
    global_index++;
    return temp;
}

// Recupera temporário a partir do símbolo
Temp *get_temp_from_symbol(char *name) {
    unsigned int index = hash(name);
    Symbol *symbol = symbolTable[index];
    if (symbol != NULL) {
        return tempTable[symbol->tempIndex];
    }
    fprintf(stderr, "Erro: Variável temporária do simbolo %s não encontrada!\n", name);
    exit(EXIT_FAILURE);
}

Campo *add_campo(int inicio, int tamanho) {
    Campo *campo = malloc(sizeof(Campo));
    if (!campo) {
      perror("malloc failed");
      exit(EXIT_FAILURE);
    }
    campo->inicio = inicio;
    campo->tamanho = tamanho;
    return campo;
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
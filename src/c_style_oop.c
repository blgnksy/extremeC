//
// Created by blgnksy on 03/12/2025.
//
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_SIZE 10

/* Encapsulation */

// related to a car object
/** Encapsulation
 * C struct can encapsulate the attributes but not the functionality. But this doesn't mean that C can not control the
 * behaviour of the object. Usually a function name starts with the struct name (xxx_t-> xxx, t is type) and then the
 * behavior. The functions take an argument which is the object type.
 * Example: `car_accelerate(car_t*)`
 */
typedef struct {
    char name[32];
    double speed;
    double fuel;
} car_t;

// the behaviors of a car object
void car_construct(car_t*, const char*);
void car_destruct(car_t*);
void car_accelerate(car_t*);
void car_brake(car_t*);
void car_refuel(car_t*, double);


void car_construct(car_t* car, const char* name) {
    strcpy(car->name, name);
    car->speed = 0.0;
    car->fuel = 0.0;
}
void car_destruct(car_t* car) {
    // Nothing to do here!
}
void car_accelerate(car_t* car) {
    car->speed += 0.05;
    car->fuel -= 1.0;
    if (car->fuel < 0.0) {
        car->fuel = 0.0;
    }
}
void car_brake(car_t* car) {
    car->speed -= 0.07;
    if (car->speed < 0.0) {
        car->speed = 0.0;
    }
    car->fuel -= 2.0;
    if (car->fuel < 0.0) {
        car->fuel = 0.0;
    }
}
void car_refuel(car_t* car, double amount) {
    car->fuel = amount;
}

/*-----------------------------------------------*/
/** Information hiding (The attribute structure with no disclosed attribute)
 * What you see in the preceding code box is the way that we make the attributes private. If another source file, such
 * as the one that contains the main function, includes the preceding header, it'll have no access to the attributes
 * inside the list_t type.  * The reason is simple. The list_t is just a declaration without a definition and with
 * just a structure declaration. (forward declaration)
 */
struct list_t;
// Allocation function
struct list_t* list_malloc();
// Constructor and destructor functions
void list_init(struct list_t*);
void list_destroy(struct list_t*);
// Public behavior functions
int list_add(struct list_t*, int);
int list_get(struct list_t*, int, int*);
void list_clear(struct list_t*);
size_t list_size(struct list_t*);
void list_print(struct list_t*);


// Define these in a source file
/** alias type bool_t
 */
typedef int bool_t;
/** type list_t
 */
typedef struct list_t {
    size_t size;
    int* items;
} list_t;

// A private behavior which checks if the list is full
bool_t __list_is_full(list_t* list) {
    return (list->size == MAX_SIZE);
}
// Another private behavior which checks the index
bool_t __check_index(list_t* list, const int index) {
    return (index >= 0 && index <= list->size);
}
// Allocates memory for a list object
list_t* list_malloc() {
    return (list_t*)malloc(sizeof(list_t));
}
// Constructor of a list object
void list_init(list_t* list) {
    list->size = 0;
    // Allocates from the heap memory
    list->items = (int*)malloc(MAX_SIZE * sizeof(int));
}
// Destructor of a list object
void list_destroy(list_t* list) {
    // Deallocates the allocated memory
    free(list->items);
}
int list_add(list_t* list, const int item) {
    // The usage of the private behavior
    if (__list_is_full(list)) {
        return -1;
    }
    list->items[list->size++] = item;
    return 0;
}
int list_get(list_t* list, const int index, int* result) {
    if (__check_index(list, index)) {
        *result = list->items[index];
        return 0;
    }
    return -1;
}
void list_clear(list_t* list) {
    list->size = 0;
}
size_t list_size(list_t* list) {
    return list->size;
}
void list_print(list_t* list) {
    printf("[");
    for (size_t i = 0; i < list->size; i++) {
        printf("%d ", list->items[i]);
    }
    printf("]\n");
}


int reverse(struct list_t* source, struct list_t* dest) {
    list_clear(dest);
    for (size_t i = list_size(source) - 1; i >= 0; i--) {
        int item;
        if(list_get(source, i, &item)) {
            return -1;
        }
        list_add(dest, item);
    }
    return 0;
}


typedef enum {
    ON,
    OFF
  } state_t;
typedef struct {
    state_t state;
    double temperature;
} engine_t;

// Memory allocator
engine_t* engine_new() {
    return (engine_t*)malloc(sizeof(engine_t));
}
// Constructor
void engine_ctor(engine_t* engine) {
    engine->state = OFF;
    engine->temperature = 15;
}
// Destructor
void engine_dtor(engine_t* engine) {
    // Nothing to do
}
// Behavior functions
void engine_turn_on(engine_t* engine) {
    if (engine->state == ON) {
        return;
    }
    engine->state = ON;
    engine->temperature = 75;
}
void engine_turn_off(engine_t* engine) {
    if (engine->state == OFF) {
        return;
    }
    engine->state = OFF;
    engine->temperature = 15;
}
double engine_get_temperature(engine_t* engine) {
    return engine->temperature;
}

/* Composition */
typedef struct my_struct
{
    /* When you are implementing a composition relationship, no pointer should be leaked out otherwise it causes
     * external code to be able to change the state of the contained object. Just like encapsulation, no pointer
     * should be leaked out when it gives direct access to the private parts of an object. Private parts should always
     * be accessed indirectly via behavior functions.
     */
     engine_t* engine;
} car1_t;
car1_t* car_new() {
    return (car1_t*)malloc(sizeof(car1_t));
}
void car_ctor(car1_t* car) {
    // Allocate memory for the engine object
    car->engine = engine_new();
    // Construct the engine object
    engine_ctor(car->engine);
}
void car_dtor(car1_t* car) {
    // Destruct the engine object
    engine_dtor(car->engine);
    // Free the memory allocated for the engine object
    free(car->engine);
}
void car_start(car1_t* car) {
    engine_turn_on(car->engine);
}
void car_stop(car1_t* car) {
    engine_turn_off(car->engine);
}

/** The car_get_engine_temperature function in the code box gives access to the temperature attribute of the engine.
 * However, there is an important note regarding this function. It uses the public interface of the engine. If you pay
 * attention, you'll see that the car's private implementation is consuming the engine's public interface. This means
 * that the car itself doesn't know anything about the implementation details of the engine. This is the way that it
 * should be. Two objects that are not of the same type, in most cases, must not know about each other's implementation
 * details. This is what information hiding dictates. Remember that the car's behaviors are considered external to the
 * engine.
 *
 * @param car
 * @return
 */
double car_get_engine_temperature(car1_t* car) {
    return engine_get_temperature(car->engine);
}

/* Aggregation */
/** Composition, which entails that a contained object is totally dependent on its container object.
 * Aggregation, in which the contained object can live freely without any dependency on its container object.
 * The fact that aggregation can be temporary between objects, but it is defined permanently between their types
 * (or classes).
 */
struct gut_t;
// Attribute structure
typedef struct {
    char* name;
    struct gun_t* gun;
} player_t;
// Memory allocator
player_t* player_new() {
    return (player_t*)malloc(sizeof(player_t));
}
// Constructor
void player_ctor(player_t* player, const char* name) {
    player->name =
        (char*)malloc((strlen(name) + 1) * sizeof(char));
    strcpy(player->name, name);
    // This is important. We need to nullify aggregation pointers
    // if they are not meant to be set in constructor.
    player->gun = NULL;
}
// Destructor
void player_dtor(player_t* player) {
    free(player->name);
}
// Behavior functions
void player_pickup_gun(player_t* player, struct gun_t* gun) {
    // After the following line the aggregation relation begins.
    player->gun = gun;
}
void player_shoot(player_t* player) {
    // We need to check if the player has picked up the gun
    // otherwise, shooting is meaningless
    if (player->gun) {
        gun_trigger(player->gun);
    } else {
        printf("Player wants to shoot but he doesn't have a gun!");
        exit(1);
    }
}
void player_drop_gun(player_t* player) {
    // After the following line the aggregation relation
    // ends between two objects. Note that the object gun
    // should not be freed since this object is not its
    // owner like composition.
    player->gun = NULL;
}


/* Inheritance */
typedef struct {
    char first_name[32];
    char last_name[32];
    unsigned int birth_year;
} person_t;
typedef struct {
    /* This syntax is totally valid in C, and in fact nesting structures by using structure variables (not pointers)
     * is a powerful setup. It allows you to have a structure variable inside your new structure that is really an
     * extension to the former.
     */
    person_t person; // Now not a pointer type
    char student_number[16]; // Extra attribute
    unsigned int passed_credits; // Extra attribute
} student_t;

int main(int argc, char** argv) {
    // Create the object variable
    car_t car;
    // Construct the object
    car_construct(&car, "Renault");
    // Main algorithm
    car_refuel(&car, 100.0);
    printf("Car is refueled, the correct fuel level is %f\n",
      car.fuel);
    while (car.fuel > 0) {
        printf("Car fuel level: %f\n", car.fuel);
        if (car.speed < 80) {
            car_accelerate(&car);
            printf("Car has been accelerated to the speed: %f\n",
        car.speed);
        } else {
            car_brake(&car);
            printf("Car has been slowed down to the speed: %f\n",
        car.speed);
        }
    }
    printf("Car ran out of the fuel! Slowing down ...\n");
    while (car.speed > 0) {
        car_brake(&car);
        printf("Car has been slowed down to the speed: %f\n",
          car.speed);
    }
    // Destruct the object
    car_destruct(&car);


    struct list_t* list1 = list_malloc();
    struct list_t* list2 = list_malloc();
    // Construction
    list_init(list1);
    list_init(list2);
    list_add(list1, 4);
    list_add(list1, 6);
    list_add(list1, 1);
    list_add(list1, 5);
    list_add(list2, 9);
    reverse(list1, list2);
    list_print(list1);
    list_print(list2);
    // Destruction
    list_destroy(list1);
    list_destroy(list2);
    free(list1);
    free(list2);

    return 0;
}
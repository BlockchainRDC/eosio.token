cmake_minimum_required(VERSION 3.5)
project(eosio_token VERSION 1.0.0)

# if no wasm root is given use default path
if(WASM_ROOT STREQUAL "" OR NOT WASM_ROOT)
   set(WASM_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

list(APPEND CMAKE_MODULE_PATH ${WASM_ROOT}/lib/cmake)
include(EosioWasmToolchain)

add_executable(eosio.token ${CMAKE_SOURCE_DIR}/src/eosio.token.cpp)
target_include_directories(eosio.token PUBLIC ${STANDARD_INCLUDES} ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(eosio.token PRIVATE ${STANDARD_LIBS})

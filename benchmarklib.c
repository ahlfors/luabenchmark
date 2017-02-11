#define LUA_LIB
#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define API(name) benchmarklib_##name
#define ENTRY(name) { #name, API(name) }


#ifdef _WIN32
#include <Windows.h>

/*
 * return system time and user time of CPU
 */
static int API(cpu_clock)(lua_State *L) {
    FILETIME fcreation, fexit, fsys, fuser;
    if (GetProcessTimes(GetCurrentProcess(), &fcreation, &fexit, &fsys, &fuser)) {
        SYSTEMTIME ssys, suser;
        if (FileTimeToSystemTime(&fsys, &ssys)) {
            lua_pushnumber(L, (lua_Number)(
                        ssys.wHour * 3600 +
                        ssys.wMinute * 60 +
                        ssys.wSecond) +
                        (lua_Number)(ssys.wMilliseconds) / 1000);
        }
        if (FileTimeToSystemTime(&fuser, &suser)) {
            lua_pushnumber(L, (lua_Number)(
                        suser.wHour * 3600 +
                        suser.wMinute * 60 +
                        suser.wSecond) +
                        (lua_Number)(suser.wMilliseconds) / 1000);
        }
    }
    return 2;
}

static int API(wall_clock)(lua_State *L) {
    LARGE_INTEGER time, freq;
    if (QueryPerformanceFrequency(&freq) && 
            QueryPerformanceCounter(&time)) {
        lua_pushnumber(L, (lua_Number)time.QuadPart / freq.QuadPart);
    }
    return 1;
}
#else
#include <sys/times.h>
#include <time.h>
#include <unistd.h>

#ifdef __MACH__  // macOS
#include <mach/mach_time.h>
#include <mach/mach.h>
#include <mach/clock.h>

#define CLOCK_MONOTONIC 1

// typdef POSIX clockid_t
typedef int clockid_t;

// mach clock port
extern mach_port_t clock_port;

int clock_gettime(clockid_t id, struct timespec *tspec) {
    mach_timespec_t mts;
    int retval = 0;

    if (id == CLOCK_MONOTONIC) {
        retval = clock_get_time(clock_port, &mts);
        if (retval != 0) {
            return retval;
        }
        tspec->tv_sec = mts.tv_sec;
        tspec->tv_nsec = mts.tv_nsec;
    } else {
        // only CLOCK_MONOTOIC clocks supported
        return -1;
    }
    return 0;
}
#endif //__MACH__

/*
 * return system time and user time of CPU
 */
static int API(cpu_clock)(lua_State *L) {
    int clk_tck = sysconf(_SC_CLK_TCK);
    struct tms buf;
    times(&buf);
    lua_pushnumber(L, ((lua_Number)buf.tms_stime/clk_tck));
    lua_pushnumber(L, ((lua_Number)buf.tms_utime/clk_tck));
    return 2;
}

static int API(wall_clock)(lua_State *L) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    float time = ts.tv_sec + 1e-9*ts.tv_nsec;
    lua_pushnumber(L, (lua_Number)time);
    return 1;
}
#endif

LUALIB_API int luaopen_benchmarklib(lua_State *L) {
    luaL_Reg libs[] = {
        ENTRY(cpu_clock),
        ENTRY(wall_clock),
        { NULL, NULL }
    };

#if LUA_VERSION_NUM >= 502 // lua 5.2+
    luaL_newlib(L, libs);
#else
    lua_createtable(L, 0, sizeof(libs)/sizeof(libs[0]));
    luaL_register(L, NULL, libs);
#endif
    return 1;
}
/*
 * CC -shared -o benchmarklib.so -fPIC -O2 benchmarklib.c -I/usr/include/LUA_VERSION 
 * -Wall -Wextra -lLUA_VERSION
 */


/*
 * Include file constants (processed in LibmysqlIncludeFiles.txt 1
 */
/* #undef HAVE_OPENSSL_APPLINK_C */
/* #undef HAVE_ALLOCA_H */
/* #undef HAVE_BIGENDIAN */
/* #undef HAVE_SETLOCALE */
/* #undef HAVE_NL_LANGINFO */
#define HAVE_DLFCN_H 1
/* #undef HAVE_FCNTL_H */
/* #undef HAVE_FLOAT_H */
/* #undef HAVE_LIMITS_H */
/* #undef HAVE_LINUX_LIMITS_H */
/* #undef HAVE_PWD_H */
/* #undef HAVE_SELECT_H */
/* #undef HAVE_STDDEF_H */
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
/* #undef HAVE_SYS_IOCTL_H */
#define HAVE_SYS_SELECT_H 1
/* #undef HAVE_SYS_SOCKET_H */
/* #undef HAVE_SYS_STREAM_H */
#define HAVE_SYS_STAT_H 1
/* #undef HAVE_SYS_SYSCTL_H */
#define HAVE_SYS_TYPES_H 1
/* #undef HAVE_SYS_UN_H */
#define HAVE_UNISTD_H 1
/* #undef HAVE_UCONTEXT_H */

/*
 * function definitions - processed in LibmysqlFunctions.txt 
 */

/* #undef HAVE_DLERROR */
/* #undef HAVE_DLOPEN */
/* #undef HAVE_GETPWUID */
/* #undef HAVE_MEMCPY */
#define HAVE_POLL 1
/* #undef HAVE_STRTOK_R */
/* #undef HAVE_STRTOL */
/* #undef HAVE_STRTOLL */
/* #undef HAVE_STRTOUL */
/* #undef HAVE_STRTOULL */
/* #undef HAVE_TELL */
/* #undef HAVE_THR_SETCONCURRENCY */
/* #undef HAVE_THR_YIELD */
/* #undef HAVE_VASPRINTF */
/* #undef HAVE_VSNPRINTF */
/* #undef HAVE_CUSERID */

/*
 * types and sizes
 */


/* #undef SIZEOF_CHARP */
#if defined(SIZEOF_CHARP)
# define HAVE_CHARP 1
#endif


/* #undef SIZEOF_INT */
#if defined(SIZEOF_INT)
# define HAVE_INT 1
#endif

/* #undef SIZEOF_LONG */
#if defined(SIZEOF_LONG)
# define HAVE_LONG 1
#endif

/* #undef SIZEOF_LONG_LONG */
#if defined(SIZEOF_LONG_LONG)
# define HAVE_LONG_LONG 1
#endif


/* #undef SIZEOF_SIZE_T */
#if defined(SIZEOF_SIZE_T)
# define HAVE_SIZE_T 1
#endif


/* #undef SIZEOF_UINT */
#if defined(SIZEOF_UINT)
# define HAVE_UINT 1
#endif

/* #undef SIZEOF_USHORT */
#if defined(SIZEOF_USHORT)
# define HAVE_USHORT 1
#endif

/* #undef SIZEOF_ULONG */
#if defined(SIZEOF_ULONG)
# define HAVE_ULONG 1
#endif

/* #undef SIZEOF_INT8 */
#if defined(SIZEOF_INT8)
# define HAVE_INT8 1
#endif
/* #undef SIZEOF_UINT8 */
#if defined(SIZEOF_UINT8)
# define HAVE_UINT8 1
#endif

/* #undef SIZEOF_INT16 */
#if defined(SIZEOF_INT16)
# define HAVE_INT16 1
#endif
/* #undef SIZEOF_UINT16 */
#if defined(SIZEOF_UINT16)
# define HAVE_UINT16 1
#endif

/* #undef SIZEOF_INT32 */
#if defined(SIZEOF_INT32)
# define HAVE_INT32 1
#endif
/* #undef SIZEOF_UINT32 */
#if defined(SIZEOF_UINT32)
# define HAVE_UINT32 1
#endif

/* #undef SIZEOF_INT64 */
#if defined(SIZEOF_INT64)
# define HAVE_INT64 1
#endif
/* #undef SIZEOF_UINT64 */
#if defined(SIZEOF_UINT64)
# define HAVE_UINT64 1
#endif

/* #undef SIZEOF_SOCKLEN_T */
#if defined(SIZEOF_SOCKLEN_T)
# define HAVE_SOCKLEN_T 1
#endif

/* #undef SOCKET_SIZE_TYPE */

#define LOCAL_INFILE_MODE_OFF  0
#define LOCAL_INFILE_MODE_ON   1
#define LOCAL_INFILE_MODE_AUTO 2
#define ENABLED_LOCAL_INFILE LOCAL_INFILE_MODE_

#define MARIADB_DEFAULT_CHARSET ""

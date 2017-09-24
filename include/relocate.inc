#macro relocate(new_location)
 #ifdef old_location
   .echo "Error: You cannot nest relocate blocks."
 #else
   #define old_location eval($)
   .org new_location
   #define g_location eval(new_location)
 #endif
#endmacro
#define .relocate relocate(

#macro endrelocate()
 #ifdef g_location
   .org $-g_location + old_location
   #undefine g_location
   #undefine old_location
 #else
   .echo "Error : No relocate statements corresponds to this endrelocate."
 #endif
#endmacro
#define .endrelocate endrelocate(
package helpers;

@:cppFileCode("#include <iostream>\n#include <windows.h>\n#include <string>")

class ResourceFunctions
{
    
    #if cpp
        @:functionCode('
            //basically the code below but for checking
            HMODULE hExe = GetModuleHandle(NULL);
            HRSRC unlockedResource = FindResourceA(hExe, MAKEINTRESOURCE(resourceID), RT_STRING);
            if (unlockedResource != NULL)
                s = TRUE;
            else
                s = FALSE;
        ')
        public static function checkHotfixExistence(s:Null<Bool> = false, resourceID:Int){return s;}

        @:functionCode('
                HMODULE hExe = GetModuleHandle(NULL);
                HRSRC unlockedResource = FindResourceA(hExe, MAKEINTRESOURCE(resourceID), RT_STRING);
                HGLOBAL globalRes = LoadResource(hExe, unlockedResource);
                const char* lockedReadableRes = reinterpret_cast<const char*>(LockResource(globalRes));
                std::string dataR = lockedReadableRes;
                long size_sheet = SizeofResource(hExe, unlockedResource);
                std::string data(lockedReadableRes, size_sheet);
                s = data.c_str();
                FreeResource(globalRes);
            ')
        public static function getHotfixResource(s:cpp.ConstCharStar = null, resourceID:Int){return s.toString();}
    #end
}
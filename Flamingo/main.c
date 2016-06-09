//
//  main.c
//  flamingOTR_bootstrap
//
//  Created by Taiki on 08/06/2016.
//  Copyright © 2016 Taiki. All rights reserved.
//

int main(int argc, char const *argv[])
{
	char * path;
	
	if(argc > 0 && argv[0] != NULL && (path = strdup(argv[0])) != NULL)
	{
		unsigned long length = strlen(path);
		
		//We are expecting a path looking like /xxx/Contents/MacOS/Flamingo
		//We want to remove everything after Contents so we can link to the dylib and the embed binary
		
		//Trim the name of the binary from the path
		while(length > 0 && path[--length] != '/');
		//Trim the MacOS from the path
		while(length > 0 && path[--length] != '/');
		
		//The path respect our expectation
		if(length > 0)
		{
			//Trim after the point we detected
			path[length] = 0;
			
			char commandLine[length * 2 + 256];
			
			//flamingOTR is the main payload which is to be injected in the app embed in the bundle
			snprintf(commandLine, sizeof(commandLine), "DYLD_INSERT_LIBRARIES=\"%s/Resources/libFlamingOTR.dylib\" %s/Resources/Flamingo.app/Contents/MacOS/Flamingo", path, path);
			
			free(path);

			system(commandLine);
		}
		else
			free(path);
	}
	
	return 0;
}
#import <Foundation/Foundation.h>
#import "SwordInstallSourceManager.h"
#import <SwordInstallSource.h>
#import <SwordManager.h>
#import <SwordModule.h>

#ifdef __cplusplus
#include <swlog.h>
#endif

#define VERSION "0.1.4"
#define MAX_STRING_BUF 256

/** forward declarations */
unsigned int convertToHex(char *string);
unsigned int convertToInt(char *string);
int getNextParam(char *string, char *nextParam);	/* string in, nextParam out */
int cmdProcessor();
void helpMode();

void initModuleInstaller(char *parameter);
void listInstallSources();
void listModulesForInstallSource(char *parameter);
void refreshInstallSource(char *parameter);
void installModuleFromSource(char *parameter);
void listModuleStatus(char *parameter);
void uninstallModule(char *parameter);


// global controller
SwordInstallSourceManager *sim;
SwordManager *swMgr;

int main (int argc, const char * argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // insert code here...
    printf("Sword module installer console\n");
    printf("Developer: Manfred Bergmann\n");
	printf("Version: %s\n", VERSION);
    printf("Type help for commands\n\n");
    
    sword::SWLog::getSystemLog()->setLogLevel(sword::SWLog::LEVEL_DEBUG);

    /* call command prompt */
    cmdProcessor();
    
    [pool release];
    return 0;
}

/*
 function to provide a simple command prompt
 where commands can be executed
 */
int cmdProcessor() {

    char cmd_line[MAX_STRING_BUF] = "";
    char cmd[MAX_STRING_BUF] = "";
	//BYTE param[MAX_STRING_BUF] = "";
    int cmd_len;      /* cannot be more than 256 */
    int stat;
    
    /* we do this as long as the user typed "exit" */
    while(strncmp(&cmd[0],"exit",4) != 0)
    {
        /* print prompt */
        printf("> ");
        /*stat = scanf("%s",&cmd_line[0]);*/
        gets(&cmd_line[0]);
        cmd_len = strlen(cmd_line);
        
        /* parse cmd out of commandline */
        if(cmd_len > 0)
        {
			stat = getNextParam(&cmd_line[0],cmd);
            cmd_len = strlen(cmd);
            if(stat > 0)
            {
                if(strncmp(&cmd[0],"help",4) == 0)
                {
                    /* help mode */
					helpMode();
                }
				else if(strncmp(&cmd[0],"init", 4) == 0)
                {                    
                    initModuleInstaller(&cmd_line[0]);
                }
				else if(strncmp(&cmd[0],"ls", 2) == 0)
                {
                    /* memtest mode */
                    listInstallSources();
                }
				else if(strncmp(&cmd[0],"lm", 2) == 0)
                {
                    listModulesForInstallSource(&cmd_line[0]);
				}
				else if(strncmp(&cmd[0],"rf", 2) == 0)
                {
                    refreshInstallSource(&cmd_line[0]);
				}
				else if(strncmp(&cmd[0],"im", 2) == 0)
                {
                    installModuleFromSource(&cmd_line[0]);
				}
				else if(strncmp(&cmd[0],"ms", 2) == 0)
                {
                    listModuleStatus(&cmd_line[0]);
				}
				else if(strncmp(&cmd[0],"um", 2) == 0)
                {
                    uninstallModule(&cmd_line[0]);
				}
				else if(strncmp(&cmd[0],"exit",4) == 0)
				{
					/* do nothing */
					printf("bye bye\n");
				}
				else
				{
					printf("unrecognized command!\n");
				}
            }
        }
    }
    
    return 0;
}

void uninstallModule(char *parameter) {

    char buf[MAX_STRING_BUF] = "";
    
    // get caption parameter
    getNextParam(&parameter[0], buf);
    NSString *name = [NSString stringWithCString:buf];
    SwordModule *mod = [swMgr moduleWithName:name];
    if(mod == nil) {
        NSLog(@"No module with that name!");
    } else {
        [sim uninstallModule:mod fromManager:swMgr];
    }
}

void listModuleStatus(char *parameter) {

    char buf[MAX_STRING_BUF] = "";
    
    // get caption parameter
    getNextParam(&parameter[0], buf);
    NSString *caption = [NSString stringWithCString:buf];
    
    NSDictionary *sources = sim.installSources;
    SwordInstallSource *is = [sources objectForKey:caption];
    if(is == nil) {
        NSLog(@"There is no such install source!");
    } else {
        NSArray *modStatus = [sim moduleStatusInInstallSource:is baseManager:swMgr];
        NSEnumerator *iter = [modStatus objectEnumerator];
        SwordModule *mod = nil;
        while((mod = [iter nextObject])) {
            NSString *status = @"";
            if([mod status] == ModStatOlder) {
                status = @"Older";
            } else if([mod status] == ModStatNew) {
                status = @"New";
            } else if([mod status] == ModStatSameVersion) {
                status = @"Same version";
            } else if([mod status] == ModStatUpdated) {
                status = @"Updated";
            } else {
                status = @"unknown";
            }
            NSLog(@"module name: %@, status: %@", [mod name], status);
        }
    }
}

void installModuleFromSource(char *parameter) {

    char buf[MAX_STRING_BUF] = "";
    
    // get caption parameter
    getNextParam(&parameter[0], buf);
    NSString *caption = [NSString stringWithCString:buf];
    
    // get modulename parameter
    memset(&buf[0], 0, MAX_STRING_BUF);
    getNextParam(&parameter[0], buf);
    NSString *moduleName = [NSString stringWithCString:buf];
    
    NSDictionary *sources = sim.installSources;
    SwordInstallSource *is = [sources objectForKey:caption];
    if(is == nil) {
        NSLog(@"There is no such install source!");
    } else {
        // check if the is has this module
        BOOL found = NO;
        NSArray *modules = [is listModules];
        NSEnumerator *iter = [modules objectEnumerator];
        SwordModule *mod = nil;
        while((mod = [iter nextObject])) {
            if([[mod name] isEqualToString:moduleName]) {
                // install this
                [is installModuleWithName:[mod name] usingManager:swMgr withInstallController:sim];
                found = YES;
                break;
            }
        }
        
        if(!found) {
            NSLog(@"Could find the module name you specified!");
        }
    }
}

void refreshInstallSource(char *parameter) {
    
    char buf[MAX_STRING_BUF] = "";
    
    // get caption parameter
    getNextParam(&parameter[0], buf);
    NSString *caption = [NSString stringWithCString:buf];
    
    NSDictionary *sources = sim.installSources;
    SwordInstallSource *is = [sources objectForKey:caption];
    if(is == nil) {
        NSLog(@"There is no such install source!");
    } else {
        [sim refreshInstallSource:is];
    }
}

void listModulesForInstallSource(char *parameter) {

    char buf[MAX_STRING_BUF] = "";
    
    // get caption parameter
    getNextParam(&parameter[0], buf);
    NSString *caption = [NSString stringWithCString:buf];
    
    NSDictionary *sources = sim.installSources;
    SwordInstallSource *is = [sources objectForKey:caption];
    if(is == nil) {
        NSLog(@"There is no such install source!");
    } else {
        NSArray *moduleList = [is listModules];
        NSLog(@"number of modules: %i", [moduleList count]);
        SwordModule *mod = nil;
        NSEnumerator *iter = [moduleList objectEnumerator];
        while((mod = [iter nextObject])) {
            NSLog(@"Name: %@", [mod name]);
        }
    }
}

void listInstallSources() {
    
    // list modules
    NSDictionary *sourceList = sim.installSources;
    SwordInstallSource *is = nil;
    NSEnumerator *iter = [sourceList objectEnumerator];
    while((is = [iter nextObject])) {
        NSLog(@"is caption: %@", [is caption]);
        NSLog(@"is directory: %@", [is directory]);
        NSLog(@"is source: %@", [is source]);
        NSLog(@"is type: %@", [is type]);
        NSLog(@"");
    }
}


/*
 init module installer
 */
void initModuleInstaller(char *parameter) {

    char buf[MAX_STRING_BUF] = "";
    
	/* parse the rest of parameters */
    // get path parameter
    getNextParam(&parameter[0], buf);
    NSString *path = [NSString stringWithCString:buf];
    sim = [[SwordInstallSourceManager alloc] initWithPath:path createPath:YES];
    // init Module Manager also
    // check for a mods.d folder in path
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"mods.d"]] == NO) {
        [fm createDirectoryAtPath:[path stringByAppendingPathComponent:@"mods.d"] attributes:nil];
    }        
    swMgr = [[SwordManager alloc] initWithPath:path];
}


/*
 help mode
 */
void helpMode()
{
    printf("\nAvailable commands:\n");
	printf("init <path>                                     :init with path\n");
	printf("ls                                              :list install sources\n");
    printf("rf <install source caption>                     :refresh install source\n");
    printf("lm <install source caption>                     :list install source modules\n");
    printf("im <install source caption> <modulename>        :install module from source\n");
    printf("um <modulename>                                 :uninstall module\n");
    printf("ms <install source caption>                     :list module status\n");
	printf("exit                                      		:exit program\n");
}

/*
 converts a string to a hex value
 */
unsigned int convertToHex(char *string)
{
	/* convert string to hex, beware of sscanf, made by hand */
	int i = 2;        /* we begin here 0x... */
	int j = 0;        /* we begin here with addr */
	unsigned int addr = 0;
	
	while(string[i] != '\0')
	{
		if(string[i] == 'a')
			addr = addr | 10;
		else if(string[i] == 'b')
			addr = addr | 11;
		else if(string[i] == 'c')
			addr = addr | 12;
		else if(string[i] == 'd')
			addr = addr | 13;
		else if(string[i] == 'e')
			addr = addr | 14;
		else if(string[i] == 'f')
			addr = addr | 15;
        else
			addr = addr | (string[i] - '0');
		if(string[i+1] != '\0')
			addr = addr << 4;
        i++;
        j++;
	}
    
	return addr;
}

/*
 converts a string to a int value
 */
unsigned int convertToInt(char *string)
{
	/* convert string to int, beware of sscanf, made by hand */
	int i = 0;
	unsigned int addr = 0;
    
	while(string[i] != '\0')
	{
		addr = addr | (string[i] - '0');
		if(string[i+1] != '\0')
			addr = addr << 4;
        i++;
	}
    
	return addr;
}

/*
 parse attributes and return the next
 */
int getNextParam(char *string, char *nextParam)
{
	int stat = 0;
	int len = 0;
    
	stat = sscanf(&string[0],"%s",&nextParam[0]);
	len = strlen(&nextParam[0]);
	/* save string end */
	nextParam[len] = '\0';
	printf("[getNextParam]: parsed param: %s\n", nextParam);
	/* copy the resulting parameter line */
	strncpy(&string[0],&string[len+1],(MAX_STRING_BUF-(len+1)));
	printf("[getNextParam]: resulting paramline: %s\n", &string[0]);
    
	return stat;
}

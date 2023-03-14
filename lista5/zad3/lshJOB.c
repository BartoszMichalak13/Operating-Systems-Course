#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <math.h>
#include <fcntl.h>
#include <linux/limits.h>

//PLAN DZIALANIA Z JOB CONTROL
//MAM LISTE PIDS
//TRZEBA JAKIES CZRY MARY Z KOMENDAMI FG BG CTRLZ JOBS
//ERGO OBSLUGA SYGNALOW
//I TAKIE TAM, BEDZIE GIT
//A I GDYBYM TEGO KOMENTARZA NIE USUNAL TO WESOLYCH SWIAT
// do we wait or not
int waitc = 1;
//add 20 - SIGSTP, 18 - SIGCONT
void signal_handler(int num) {
	
	// if signal is SIGCHLD, let's wait for it
	if (num == 17) {
		waitpid(-1, NULL, WNOHANG);
	
	// we ignore SIGINT
	} else if (num == 2) {}
	//cos mi ten ctrl z nie dziala jak powinien
	else if(num == 20){
		//kill(getpid(),SIGCONT);
		//swaitpid(-1, NULL, WSTOPPED);
		//signal(SIGCONT,SIG_DFL);
		//waitc=1;
		//signal(SIGTSTP, signal_handler);
		
		printf("\n[%d] STOPPED\n", getpid());
		//sprintf(filename, "/proc/%d/stat", getpid());
		//system("/");
		//printf("\n[%d] SHOULD CONTINUE\n", MAINPID);
		//kill(MAINPID, SIGCONT);
		
		//waitpid(-1, NULL, WUNTRACED);
		//printf("[%d] STOPPED", getpid());
	}else if(num == 18){
	
	}
}

// reads prompt, counts words
int promptRead (char* outputarray[]) {
	char input[PATH_MAX];
	char* word;
	
	// will be used by strtok as separator
	char s[2] = " ";
	
	// currect dir
	char cwd[PATH_MAX];
	getcwd(cwd, sizeof(cwd));
	
	// print
	printf("[\e[38;5;160mLSH \e[38;5;33m%s\e[0m] ", cwd);
	fgets(input, PATH_MAX, stdin);

	// ignore newline chars
	if ( strlen(input) > 0 && input[strlen(input) - 1] == '\n' ) {
		input[strlen(input) - 1] = '\0';
	}
	
	//return value
	int i = 0;
	
	word = strtok(input, s);
	while (word != NULL) {
		outputarray[i] = calloc(strlen(word) + 1, sizeof(char));
		strcpy(outputarray[i], word);
		i++;
		word = strtok(NULL, s);//strtok this way == we seek where we started
	}
	return i;
}

void addRedirects(int size, char* commands[][size], int index, int mode) {
	
	int commandLength = 0;
	while ( commands[index][commandLength] != NULL ) commandLength++;
	
	for(int j = 0; j < commandLength; j++) {
		//write / all
		if( commands[index][j][0] == '>' && (mode == 1 || mode == 2) ) {
			
			char path[PATH_MAX];
			for( int k = 1; k < strlen(commands[index][j]); k++ ) {
				path[k-1] = commands[index][j][k];
			}
			
			int file;
			if ( (file = open(path, O_RDWR | O_CREAT | O_APPEND)) == -1 ) {
				perror("> error");
				_exit(1);
			}
			
			if ( dup2(file, 1) == -1 ) {
				perror("dup2 error when tryging to redirect to file");
			}
						
			commands[index][j] = NULL;
			//this is error so whatever				
		} else if ( commands[index][j][0] == '2' && commands[index][j][1] == '>' ) {
					
			char path[PATH_MAX];
			for( int k = 2; k < strlen(commands[index][j]); k++ ) {
				path[k-2] = commands[index][j][k];
			}
						
			int file;
			if ( (file = open(path, O_RDWR | O_CREAT | O_APPEND)) == -1 ) {
				perror("2> error");
				_exit(1);
			}
			if ( dup2(file, 2) == -1 ) {
				perror("dup2 error when tryging to redirect to file");
			}
					
			commands[index][j] = NULL;
			//read / all
		} else if ( commands[index][j][0] == '<' && (mode == 0 || mode == 2) ) {
			
			char path[PATH_MAX];
			for( int k = 1; k < strlen(commands[index][j]); k++ ) {
				path[k-1] = commands[index][j][k];
			}
			
			int file;
			if ( (file = open(path, O_RDWR | O_CREAT | O_APPEND)) == -1 ) {
				perror("> error");
				_exit(1);
			}
			
			if ( dup2(file, 0) == -1 ) {
				perror("dup2 error when tryging to redirect to file");
			}
						
			commands[index][j] = NULL;

		}
	}
}

void CommandHandler(char* pipedCommands[], int size) {

	// stores index for last | symbol
	int foundIndex = size;
	int commandsCount = 0;
	char* commands[size][size];
	for (int i = size - 1; i > -1; i--) {
		if (pipedCommands[i][0] == '|' || i == 0) {
			int k = 0;
			
			// we want to ignore | unless we're on the first char, then there's no | to ignore
			int j = i + 1;
			if (i == 0) {
				j = 0;
			}
			// split each command into separate words
			for (; j < foundIndex; j++) {
				// commands is allocated and written to and yet we don't ever free it, because the process dies eventually, so, whatever
				commands[commandsCount][k] = calloc(strlen(pipedCommands[j]) + 1, sizeof(char));
				strcpy(commands[commandsCount][k], pipedCommands[j]);
				k++;
			}
			commands[commandsCount][k] = NULL;
			
			commandsCount++;
			foundIndex = i;
		}
	}
	
	// create fds shared between forks (later)
	int fd[commandsCount - 1][2];
	for (int i = 0; i < commandsCount - 1; i++) {
		if (pipe(fd[i]) == -1) {
			perror("pipe error");
		}
	}
	
	// we will store processes pids to wait for them later
	int pids[commandsCount];
	int status, wpid;

	for (int i = 0; i < commandsCount; i++) {
		if ((pids[i] = fork()) == 0) {
			
			if (commandsCount > 1) {
				if (i == 0) {
					// case for the LAST command in pipes
					if (dup2(fd[i][0], 0) == -1) {
						perror("dup2 error on i=0");
					}
					
					addRedirects(size, commands, i, 1);
					
				} else if (i != commandsCount - 1) {
					// case for all the MIDDLE commands in pipes
					if (dup2(fd[i-1][1], 1) == -1) {
						perror("dup2 error");
					}
					if (dup2(fd[i][0], 0) == -1) {
						perror("dup2 error");
					}
					
					addRedirects(size, commands, i, -1);
					
				} else {
					// case for the FRIST command in pipes
					if (dup2(fd[i-1][1], 1) == -1) {
						perror("dup2 error on i=commands-1");
					}
					
					addRedirects(size, commands, i, 0);
				}
			} else {
				// if we have only one command, we add all redirects to it
				addRedirects(size, commands, 0, 2);
			}
			
			// we close all unused fds
			for (int j = 0; j < commandsCount - 1; j++) {
				close(fd[j][0]);
				close(fd[j][1]);
			}
			
			// we execute the command - process is replaced by it and dies off eventually, freeing resources
			execvp(commands[i][0], commands[i]);
			// being here means execvp failed
			perror("execvp error");
			_exit(1);
			
		}
	}
	for (int j = 0; j < commandsCount - 1; j++) {
		close(fd[j][0]);
		close(fd[j][1]);
	}
	
	// if we decided to wait
	if(waitc) {
		for(int i = commandsCount - 1; i > -1; i--) {
			if(pids[i] > 0) {
				int status;
				waitpid(pids[i], &status, 0);
			} 
		}
	}
	exit(0);
}

int main() {
	char* words[PATH_MAX];
	/*
	struct sigaction sa;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART;
	sa.sa_handler = signal_handler;	
	if (sigaction(SIGINT, &sa, NULL) == -1)
		errExit("sigaction");
	if (sigaction(SIGTSTP, &sa, NULL) == -1)
		errExit("sigaction");
	if (sigaction(SIGCONT, &sa, NULL) == -1)
		errExit("sigaction");
		*/
	//signal(SIGTSTP, signal_handler);
	signal(SIGTSTP, signal_handler);
	signal(SIGCHLD, signal_handler);
	signal(SIGINT, SIG_IGN);
	int lshpgid=getpgid(0);
	//signal(SIGQUIT, signal_handler);
	while(1) {
		int i = promptRead(words);
	
		if (i == 0) {
			 continue;
		}
		
		int status, wpid;
		
		// cd and exit handled here, potentialy jobs also
		if (words[0][0] == 'c' && words[0][1] == 'd' && words[0][2] == '\0') {
			chdir(words[1]);
			continue;
		} else if (words[0][0] == 'e' && words[0][1] == 'x' && words[0][2] == 'i' && words[0][3] == 't' && words[0][4] == '\0') {
			kill(0, 9);
			exit(0);
		} else if (words[0][0] == 'j' && words[0][1] == 'o' && words[0][2] == 'b' && words[0][3] == 's' && words[0][4] == '\0') {
			//PLAN wziac wszystkie procesy, z nich wybrac te ktore maja PGID=lshpgid, i je wypisac
			//printf("czy ja tu weszlem 1\n");
			int pid[1024];
			for(int l=0; l<1024; ++l)
				pid[l]=calloc(4, sizeof(int));
			system("ls /proc > info_proc.txt");
			FILE *f1 = fopen("info_proc.txt", "r");
			//change for strings
			//add k
			int k=0;
			int j=0;//number of pids
			char pidinchar[5]={0x0};
			
			char symb;
			unsigned char symb1;

			while((symb=getc(f1))!=EOF){
				symb1=(unsigned char) symb;
				if(symb1 >= '0' && symb1 <= '9'){
					pidinchar[k]=symb1;
					++k;
				}
				if(symb==10){
					pid[j]=atoi(pidinchar);
					k=0;
					++j;
				}
			}
			fclose(f1);
			
			int pgid[1024];
			for(int l=0; l<1024; ++l)
				pgid[l]=calloc(4, sizeof(int));
			char status[1024];
			for(int l=0; l<1024; ++l)
				status[l]=calloc(1, sizeof(char));
			char filename[1000];
			char name[1024][1000];
			for(int l=0; l<1024; ++l)
				for(int o=0;o<1000;++o)
					name[l][o]=calloc(1, sizeof(char));
			for(int l=0; l<j; ++l){
				//system("ls /proc > info_pid.txt");
				//FILE *f1 = fopen("info_pid.txt", "r");
				sprintf(filename, "/proc/%d/stat", pid[l]);
			
				if (access(filename, R_OK)==0){
					FILE *f = fopen(filename, "r");
					int unused;//pid - unused
					char comm[1000];//unused
					char state;//unused
					int ppid;//unused
					int pgid1;
					
					rewind(f);
					fscanf(f, "%d %s %c %d %d", &unused, comm, &state, &ppid, &pgid1);
					
					//we have pid and pgid
					pgid[l]=pgid1;
					for(int k=0;k<1000;k++)
						name[l][k]=comm[k];
					status[l]=state;
					//printf("%d	%s	%c	%d\n",pid[l],comm,status[l],pgid[l]);
					fclose(f);
				}
			}
			//great now we check if pgid is equal to lshpgid
			int max=0;
	
			int npid[1024];
			char nstatus[1024];
			int npgid[1024];
			char nname[1024][1000];
			int x=0;
			for (int l=0; l<j; ++l){
			
				if(pgid[l]==lshpgid){
					npid[x]=pid[l];
					nstatus[x]=status[l];	
					npgid[x]=pgid[l];
					for(int k=0;k<1000;k++)
						nname[x][k]=nname[l][k];
					x++;
				}
			}
			//HAHA NOW WE HAVE PID AND PGID
			//now make fg bg jobs and handle ctrl z :))))))
			for(int l=0;l<x;++l)
				printf("[%d] %c	%s		PGID: %d\n",npid[l],nstatus[l],nname[l],npgid[l]);
			continue;
		}
		
		// waitc handled here
		if (words[i-1][0] == '&' && words[i-1][1] == '\0') {
			waitc = 0;
			i--;
		} else {
			waitc = 1;
		}
		
		//let's let children catch SIGINT to exit
		//signal(SIGTSTP, signal_handler);
		signal(SIGINT, SIG_DFL);
		signal(SIGCHLD, signal_handler);
		//signal(SIGQUIT, signal_handler);
		
		//if(check_for_EOF())
		//	exit(0);		
		int child = fork();
		
		if (child == 0) {
			CommandHandler(words, i);
						//signal(SIGTSTP, SIG_DFL);
			
		} else {

			signal(SIGINT, SIG_IGN);
			signal(SIGTSTP, SIG_IGN);
			if (waitc) {
				wpid = waitpid(child, &status, 0);
				//will it ork?
				//wpid = waitpid(child, &status, WSTOPPED);
			}
		}
		
		// let's free memory before allocating it again
		while (0 < --i) free(words[i]);
	}
	return 0;
}

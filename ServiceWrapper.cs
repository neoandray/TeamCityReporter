using System;   
using System.Collections;   
using System.IO;   
using System.ComponentModel;   
using System.Configuration;   
using System.Data;   
using System.Web.Services;   
using System.Diagnostics;   
using System.ServiceProcess;   
using System.Reflection;
using System.Threading;
using System.Configuration.Install;

    namespace serviceinstaller{
	[RunInstaller(true)]
	public class ServiceInstaller : System.Configuration.Install.Installer {
		
		public System.ServiceProcess.ServiceProcessInstaller serviceProcessInstaller1;
		private System.ServiceProcess.ServiceInstaller serviceInstaller;
		private System.ComponentModel.Container components = null;
		private ServiceAccount account;
		private string username;
		private string password;
		private string displayName;
		private string serviceName;
		private ServiceStartMode startMode;
		private bool useSystemAccount;
		
		 
		public ServiceInstaller() {

			this.displayName =    "TeamCityReporter";
			this.serviceName =    "TeamCityReporter";
			this.startMode   =   ServiceStartMode.Automatic; 
			this.account     =   ServiceAccount.LocalService;
			InitializeComponent();
			
		}
		
		public ServiceInstaller(bool useSystemAccount,ServiceAccount account, string username, string password, string displayName, string serviceName,ServiceStartMode startMode ){
			
			 this.account     	  =   account;
			 this.useSystemAccount=   useSystemAccount;
			 if(!this.useSystemAccount){
				 
				 this.username    =   username;
				 this.password    =   password;
				 
			 }
			 this.displayName 	  =   displayName;
			 this.serviceName 	  =   serviceName;
			 this.startMode  	  =   startMode; 
			
		}
		
		public ServiceInstaller(ServiceAccount account,string displayName, string serviceName,ServiceStartMode startMode ){
			
			 this.displayName =   displayName;
			 this.serviceName =   serviceName;
			 this.startMode   =   startMode; 
			 this.account     =   account;
				
		}
		
		protected override void Dispose( bool disposing ) {
			if(disposing) {
				
				if(components != null) {
					
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}
		#region Component Designer generated code
		private void InitializeComponent() {
			
			this.serviceProcessInstaller1          = new System.ServiceProcess.ServiceProcessInstaller();
			this.serviceInstaller 				   = new System.ServiceProcess.ServiceInstaller();
			this.serviceProcessInstaller1.Account  = this.account; 	   //System.ServiceProcess.ServiceAccount.LocalService;
			this.serviceProcessInstaller1.Password = this.password;
			this.serviceProcessInstaller1.Username = this.username;
			this.serviceInstaller.DisplayName 	   = this.displayName; //"Test Installer";
			this.serviceInstaller.ServiceName      = this.serviceName; //"BuilderService";
			this.serviceInstaller.StartType        = this.startMode;   //System.ServiceProcess.ServiceStartMode.Automatic;
			this.serviceInstaller.Description      = "Reno TeamCity Monitoring Service.";
			this.Installers.AddRange(new System.Configuration.Install.Installer[] {this.serviceProcessInstaller1,this.serviceInstaller});
			
		}
	#endregion
	} 
	

public class ServiceWrapper : System.ServiceProcess.ServiceBase   
{      
public System.ComponentModel.Container components;  
public string customServiceName 	= "DefaultServiceName"; 
public System.Diagnostics.EventLog eventLogger; 
public int processId;
public string serviceDirectory		="C:\\Users\\jgw51912\\Documents\\T\\TeamCity";  //System.Reflection.Assembly.GetEntryAssembly().Location
public int subProcessID;
public ServiceWrapper() {    
             try{ 
               string serviceNameStr = this.serviceDirectory+"\\"+"servicename.txt"; 
			   this.customServiceName = File.ReadAllText(serviceNameStr).Trim();
			 }catch(Exception e){
			   	 Console.WriteLine(e.StackTrace);
			 }
           InitializeComponent();  
    }  
  
       public void Verify(string[] args)  
       {  
           this.OnStart(args);   
  
           this.OnStop();  
       }  
     
	         public  void writeStandardOutput(StreamReader standandOutput, string outputFile)
        {
            using (StreamWriter writer = File.CreateText(outputFile))
            using (StreamReader reader = standandOutput)
            {
                writer.AutoFlush = true;

                for (;;)
                {
                    string textLine = reader.ReadLine();

                    if (textLine == null)
                        break;

                    writer.WriteLine(textLine);
                }
            }

            if (File.Exists(outputFile))
            {
                FileInfo info = new FileInfo(outputFile);

                // if the error info is empty or just contains eof etc.

                if (info.Length < 4)
                    info.Delete();
            }
        }

        /// <summary>Thread which outputs standard error output from the running executable to the appropriate file.</summary>

        public  void writeStandardError(StreamReader standardError, string errorFile)
        {
            using (StreamWriter writer = File.CreateText(errorFile))
            using (StreamReader reader = standardError)
            {
                writer.AutoFlush = true;

                for (;;)
                {
                    string textLine = reader.ReadLine();

                    if (textLine == null)
                        break;

                    writer.WriteLine(textLine);
                }
            }

            if (File.Exists(errorFile))
            {
                FileInfo info = new FileInfo(errorFile);

                // if the error info is empty or just contains eof etc.

                if (info.Length < 4)
                    info.Delete();
            }
        }
static void Main(string[] args)   
{   

    if (Environment.UserInteractive) {
        var parameter = string.Concat(args);
        switch (parameter) {
            case "--install":
                ManagedInstallerClass.InstallHelper(new[] { Assembly.GetExecutingAssembly().Location });
				//new ServiceInstaller(ServiceAccount.LocalService, "TeamCityReporter","TeamCityReporter",ServiceStartMode.Automatic);
				//ManagedInstallerClass.InstallHelper(new ServiceInstaller(ServiceAccount.LocalService, "TeamCityReporter","TeamCityReporter",ServiceStartMode.Automatic));
                break;
            case "--uninstall":
                ManagedInstallerClass.InstallHelper(new[] { "/u", Assembly.GetExecutingAssembly().Location });
                break;
        }
    } else {     
			System.ServiceProcess.ServiceBase.Run( new System.ServiceProcess.ServiceBase[] { new ServiceWrapper() });   
	}
}   

public void InitializeComponent()   
{   
		    components = new System.ComponentModel.Container();  
            this.eventLogger = new System.Diagnostics.EventLog();  
			
			if (!System.Diagnostics.EventLog.SourceExists(customServiceName))  { 

				System.Diagnostics.EventLog.CreateEventSource(customServiceName,"Application"); 

			} 
			this.eventLogger.Source =	customServiceName;
			this.eventLogger.Source =	"Application";

            ((System.ComponentModel.ISupportInitialize)(this.eventLogger)).BeginInit();  
            this.CanHandleSessionChangeEvent = true;   
			 this.ServiceName = this.customServiceName;
            ((System.ComponentModel.ISupportInitialize)(this.eventLogger)).EndInit();  
}   

public void runService(){

            Process process                               = new Process();
            ProcessStartInfo startInfo                    = new ProcessStartInfo();
            startInfo.WindowStyle                         = ProcessWindowStyle.Hidden;
            startInfo.FileName                            = "powershell.exe";
            startInfo.UseShellExecute                     = false;
            startInfo.RedirectStandardError               = true;
            string errorFile                              = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location)+"\\error.log";
            startInfo.RedirectStandardOutput              = true;
            string outputFile                             = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location)+"\\agent.log";
            startInfo.WorkingDirectory                    = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location);
            startInfo.WindowStyle                         = ProcessWindowStyle.Hidden;
            startInfo.Arguments                           = "-executionPolicy Bypass -File "+Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location)+"\\StartTeamCityReporter.ps1";
            process.StartInfo                             = startInfo;          
            process.Start();
            Thread outWriterThread                        = new Thread(() => writeStandardOutput( process.StandardOutput,outputFile));
            outWriterThread.IsBackground = true ;
            outWriterThread.Name = "OutputWriterThread";
            outWriterThread.Start();

            Thread errorWriterThread = new Thread(() => writeStandardError( process.StandardError,errorFile));
            errorWriterThread.IsBackground = true ;
            errorWriterThread.Name = "ErrorWriterThread";
            errorWriterThread.Start();
   
           process.WaitForExit();

    
}

protected override void OnStart(string[] args)   
{   
  
  Thread  startService =  new Thread(runService);
  startService.Start();
  this.processId = startService.ManagedThreadId;


		
}   
 
protected override void OnStop()   
{   
   Process[] process    = null;  
   Process subProcess = null;
   Process currentProcess = null;

           try  
           {  
				string pidPath = this.serviceDirectory+"\\"+"pid.txt"; 
				string pidString = File.ReadAllText(pidPath).Trim();
				this.subProcessID = Int32.Parse(pidString) ;
                process = Process.GetProcessesByName("TeamCityReporter.exe"); 
			    subProcess = Process.GetProcessById( this.subProcessID ); 
			     currentProcess = Process.GetCurrentProcess();
           }  
           finally  
           {  
			if(subProcess!=null){
					subProcess.Kill();  
					subProcess.WaitForExit();  
					subProcess.Dispose(); 
			}
               if (process != null)   
               {   
		         	foreach(Process proc in process){
                   proc.Kill();  
                   proc.WaitForExit();  
                   proc.Dispose(); 
					}				   
               }  
			/*if(currentProcess!=null){
					currentProcess.Kill();  
					currentProcess.WaitForExit();  
					currentProcess.Dispose(); 
			}
			*/			
           } 
} 
  
}   
	}
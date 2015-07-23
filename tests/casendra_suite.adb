with Aunit.Test_Suites; use Aunit.Test_Suites; 
with Casendra.Test_Downloader;
with Casendra.Test_Download_All;
with Casendra.Test_Cleaner;
function Casendra_Suite return Access_Test_Suite is
   TS_Ptr : constant Access_Test_Suite := new Test_Suite; 
begin
   Ts_Ptr.Add_Test (new Casendra.Test_Downloader.Tc);
   Ts_Ptr.Add_Test (new Casendra.Test_Cleaner.Tc);
   Ts_Ptr.Add_Test (new Casendra.Test_Download_All.Tc);
   return Ts_Ptr;
end Casendra_Suite;

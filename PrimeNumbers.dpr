program PrimeNumbers;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  PrimeNumberCalculation in 'PrimeNumberCalculation.pas',
  Logger in 'Services\Logger.pas',
  LoggerInterface in 'Interfaces\LoggerInterface.pas',
  System.SysUtils;

const
  TopLimit: Cardinal = 1000000;
  ThreadCount = 2;
var
  APercent: Integer = -1;

procedure ShowProgress(APrimeNumber: Cardinal);
var
  ANewPercent: Integer;
begin
  ANewPercent := Round(APrimeNumber * 100 / TopLimit);
  if ANewPercent = APercent then
  begin
    Write('.');
    exit;
  end;

  WriteLn;
  Write(Format('%2d%% is done.', [ANewPercent]));
  APercent := ANewPercent;
end;

var
  ALoggers: TArray<ILogger>;
  ACommonLogger: IThreadSafeLogger;
  I: Integer;
begin
  SetLength(ALoggers, ThreadCount);
  for I := 0 to ThreadCount - 1 do
    ALoggers[i] := TLogger.Create(nil, Format('Thread%d.txt', [i + 1]));
  ACommonLogger := TThreadSafeLogger.Create(nil, 'Result.txt');

  Write(Format('Starting calculation of prime numbers with top limit %d.', [TopLimit]));
  TPrimeNumberCalculation.Start(TopLimit, ACommonLogger, ALoggers, ShowProgress);
  WriteLn;
  Write('Calculation is done.');
  Readln;
end.

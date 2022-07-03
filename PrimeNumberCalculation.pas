unit PrimeNumberCalculation;

interface

uses
  System.SyncObjs, System.Classes, System.Generics.Collections,
  LoggerInterface, System.SysUtils;

type
  TProgressProc = reference to procedure(APrimeNumber: Cardinal);

  TPrimeNumberCalculation = class(TObject)
  private
    class procedure CalcPrimeNumbers(ATopLimit: Cardinal; AThreadSafeLogger:
        IThreadSafeLogger; ALogger: ILogger); static;
    class function GetCalcPrimeNumbers(ATopLimit: Cardinal; AThreadSafeLogger:
        IThreadSafeLogger; ALogger: ILogger): TProc; static;
  public
    class procedure Start(ATopLimit: Cardinal; ACommonLogger: IThreadSafeLogger;
        AThreadLoggers: TArray<ILogger>; AProgress: TProgressProc; AProgressRate:
        Integer = 1000); static;
  end;

implementation

uses
  System.Threading;

class procedure TPrimeNumberCalculation.CalcPrimeNumbers(ATopLimit: Cardinal;
    AThreadSafeLogger: IThreadSafeLogger; ALogger: ILogger);
var
  ALastNumber: Cardinal;
  ANumber: Cardinal;
  IsPrimeNumber: Boolean;
  AMaxDivisor: Cardinal;
  APrimeNumber: Cardinal;
  APrimeNumbers: TList<Cardinal>;
begin
  ANumber := 1;
  APrimeNumbers := TList<Cardinal>.Create;
  try
    while ANumber < ATopLimit do
    begin
      Inc(ANumber);
      AMaxDivisor := Trunc( Sqrt(ANumber) );

      IsPrimeNumber := True;
      for APrimeNumber in APrimeNumbers do
      begin
        if APrimeNumber > AMaxDivisor then Break;

        if ANumber mod APrimeNumber <> 0 then Continue;

        IsPrimeNumber := False;
        Break;
      end;

      if not IsPrimeNumber then Continue;

      APrimeNumbers.Add(ANumber);
      if AThreadSafeLogger.TryAdd(ANumber, ALastNumber) then
        ALogger.Add(ANumber)
      else
        ANumber := ALastNumber;
    end;
  finally
    FreeAndNil(APrimeNumbers);
  end;
end;

class function TPrimeNumberCalculation.GetCalcPrimeNumbers(ATopLimit: Cardinal;
    AThreadSafeLogger: IThreadSafeLogger; ALogger: ILogger): TProc;
begin
  Result := procedure begin CalcPrimeNumbers(ATopLimit, AThreadSafeLogger, ALogger); end;
end;

class procedure TPrimeNumberCalculation.Start(ATopLimit: Cardinal;
    ACommonLogger: IThreadSafeLogger; AThreadLoggers: TArray<ILogger>;
    AProgress: TProgressProc; AProgressRate: Integer = 1000);
var
  Tasks: array of ITask;
  i: Integer;
begin
  Assert(Length(AThreadLoggers) > 0);

  SetLength(Tasks, Length(AThreadLoggers));
  for i := 0 to Length(AThreadLoggers) - 1 do
  begin
    Tasks[i] := TTask.Create(GetCalcPrimeNumbers(ATopLimit, ACommonLogger, AThreadLoggers[i]));
    Tasks[i].Start;
  end;

  while True do
  begin
    if not TTask.WaitForAll(Tasks, AProgressRate) then
      AProgress(ACommonLogger.LastNumber)
    else
      Break;
  end;
end;

end.

unit Logger;

interface

uses
  LoggerInterface, System.Classes, System.SyncObjs;

type
  TLogger = class (TComponent, ILogger)
  private
    FFileName: string;
    FIsEmpty: Boolean;
    procedure CreateEmptyFile(AFileName: string);
  protected
    procedure Add(ANumber: Cardinal);
  public
    constructor Create(AOwner: TComponent; const AFileName: string); reintroduce;
        virtual;
  end;

  TThreadSafeLogger = class(TLogger, IThreadSafeLogger)
  strict private
    function GetLastNumber: Cardinal;
  private
    FCS: TCriticalSection;
    FLastNumber: Cardinal;
  class var
    function TryAdd(ANumber: Cardinal; out ALastNumber: Cardinal): Boolean;
  public
    constructor Create(AOwner: TComponent; const AFileName: string); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.StrUtils;

constructor TThreadSafeLogger.Create(AOwner: TComponent; const AFileName: string);
begin
  inherited Create(AOwner, AFileName);
  FCS := TCriticalSection.Create;
  FLastNumber := 0;
end;

destructor TThreadSafeLogger.Destroy;
begin
  inherited;
  FCS.Free;
end;

function TThreadSafeLogger.GetLastNumber: Cardinal;
begin
  FCS.Enter;
  try
    Result := FLastNumber;
  finally
    FCS.Release;
  end;
end;

function TThreadSafeLogger.TryAdd(ANumber: Cardinal; out ALastNumber:
    Cardinal): Boolean;
begin
  FCS.Enter;
  try
    if ANumber <= FLastNumber then
    begin
      ALastNumber := FLastNumber;
      Exit(false);
    end;

    Add(ANumber);
    FLastNumber := ANumber;
    ALastNumber := ANumber;
    Result := True;
  finally
    FCS.Leave;
  end;
end;

constructor TLogger.Create(AOwner: TComponent; const AFileName: string);
begin
  inherited Create(AOwner);
  FFileName := AFileName;
  CreateEmptyFile(AFileName);
  FIsEmpty := True;
end;

procedure TLogger.Add(ANumber: Cardinal);
var
  S: string;
begin
  S := IfThen(FIsEmpty, '', ' ') + ANumber.ToString;
  TFile.AppendAllText(FFileName, S);
  FIsEmpty := False;
end;

procedure TLogger.CreateEmptyFile(AFileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFile.Create(AFileName);
  Stream.Free;
end;

end.

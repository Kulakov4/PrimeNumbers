unit LoggerInterface;

interface

type
  ILogger = interface(IInterface)
    procedure Add(ANumber: Cardinal);
  end;

  IThreadSafeLogger = interface(IInterface)
    function GetLastNumber: Cardinal;
    function TryAdd(ANumber: Cardinal; out ALastNumber: Cardinal): Boolean;
    property LastNumber: Cardinal read GetLastNumber;
  end;

implementation

end.

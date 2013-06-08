unit RecordNumber;

interface
const EMPTY_NUMBER = Int64(0);
const BOF_NUMBER = Int64(-1);
const STUFF_COUNT		= 4;
const END_LEVEL		= -1;
const END_BUCKET		= -2;
const btr_large_keys = 32;
const BTN_NORMAL_FLAG		= 0;
const BTN_END_LEVEL_FLAG	= 1;
const BTN_END_BUCKET_FLAG	= 2;
const BTN_ZERO_PREFIX_ZERO_LENGTH_FLAG	= 3;
const BTN_ZERO_LENGTH_FLAG	= 4;
const BTN_ONE_LENGTH_FLAG	= 5;

function get_long(p : PByte) : longint;

 type
 TPacked = class(TObject)
   	public
		bid_relation_id : word; // Relation id (or null)
    private
		bid_reserved_for_relation : Byte;	// Reserved for future expansion of relation space.
		bid_number_up : Byte;				// Upper byte of 40-bit record number
		bid_number : Byte;					// Lower bytes of 40-bit record number
											          // or 32-bit temporary ID of blob or array
    public
    function bid_temp_id() : longint;
    procedure bid_encode(value : int64 );
    function bid_decode : int64;
 end;
 TRecordNumber = class(TObject)
   private
	 // Use signed value because negative values are widely used as flags in the
	 // engine. Since page number is the signed 32-bit integer and it is also may
	 // be stored in this structure we want sign extension to take place.
	 value : int64;
   valid : boolean;
   public
   Pckd : TPacked;
   constructor Create(); overload;
   constructor Create(from : TRecordNumber); overload;
   constructor Create(number : int64); overload;
   procedure AsignRN(from : TRecordNumber);
   procedure setValue(avalue : int64);
   function getValue() : int64;

 end;

implementation


function get_long(p : PByte) : longint;
var temp : longint;
begin
  Move( p, temp, sizeof(longint) );
  result := temp;
end;

function TPacked.bid_temp_id() : longint;
begin
  result := bid_number;
end;

// Handle encoding of record number for RDB$DB_KEY and BLOB ID structure.
// BLOB ID is stored in database thus we do encode large record numbers
// in a manner which preserves backward compatibility with older ODS.
// The same applies to bid_decode routine below.
procedure TPacked.bid_encode(value : int64);
begin
  // Store lower 32 bits of number
  bid_number := value;
  // Store high 8 bits of number
  bid_number_up := value shr 32;
end;

function TPacked.bid_decode : int64;
begin
		result :=  bid_number + (int64(bid_number_up) shl 32);
end;

{*************************************}
constructor TRecordNumber.Create();
begin
  value := EMPTY_NUMBER;
  valid := false;
end;

constructor TRecordNumber.Create(from : TRecordNumber);
begin
  value := from.value;
  valid := from.valid;
end;

constructor TRecordNumber.Create(number : int64);
begin
  value := number;
  valid := true;
end;

procedure TRecordNumber.AsignRN(from : TRecordNumber);
begin
  value := from.value;
end;

procedure TRecordNumber.setValue(avalue : int64);
begin
  value := avalue;
end;

function TRecordNumber.getValue() : int64;
begin
  result := value;
end;


end.


{-------------------------------------------------------}
{ from Crenshaw compiler tutorial, some modifications }
{ by txb }
program Cradle;



{-------------------------------------------------------}
{ Constant Declarations }
const
	TAB = ^I;


{-------------------------------------------------------}
{ Global variable declarations }
var
	Look: char;              { Lookahead Character }



{-------------------------------------------------------}
{ Read New Character From Input Stream }
procedure GetChar;
begin
	Read(Look);
end;



{-------------------------------------------------------}
{ Report an Error }
procedure Error(s: string);
begin
	WriteLn;
	WriteLn(^G, 'Error: ', s, '.');
end;



{-------------------------------------------------------}
{ Report Error and Halt }
procedure Abort(s: string);
begin
	Error(s);
	Halt;
end;



{-------------------------------------------------------}
{ Report What Was Expected but not found }
procedure Expected(s: string);
begin
	Abort(s + ' Expected');
end;



{-------------------------------------------------------}
{ Match a Specific Input Character }
procedure Match(x: char);
begin
	if Look = x then
		GetChar
	else
		Expected('''' + x + '''');
end;



{-------------------------------------------------------}
{ Recognize an Alpha Character }
function IsAlpha(c: char): boolean;
begin
	IsAlpha := upcase(c) in ['A'..'Z'];
end;
	                          


{-------------------------------------------------------}
{ Recognize a Decimal Digit }
function IsDigit(c: char): boolean;
begin
	IsDigit := c in ['0'..'9'];
end;



{-------------------------------------------------------}
{ Recognize an alphanumeric }
function IsAlNum(c: char): boolean;
begin
	IsAlNum := IsAlpha(c) or IsDigit(c);
end;



{-------------------------------------------------------}
{ check for lineend, the original test for const ^M is  }
{ not safe in today's world of mixed platforms.         }
function IsLineEnd(c: char): boolean;
begin
	IsLineEnd := ord(c) in [10, 13];
end;



{-------------------------------------------------------}
{ Get an Identifier }
function GetName: char;
begin
	if not IsAlpha(Look) then
		Expected('Name');
	GetName := UpCase(Look);
	GetChar;
end;



{-------------------------------------------------------}
{ Get a Number }
function GetNum: char;
begin
	if not IsDigit(Look) then
		Expected('Integer');
	GetNum := Look;
	GetChar;
end;



{-------------------------------------------------------}
{ test for valid addition operator }
function IsAddop(c: char): boolean;
begin
	IsAddop := c in ['+', '-'];
end;



{-------------------------------------------------------}
{ test for valid multiplication operator }
function IsMulop(c: char): boolean;
begin
	IsMulop := c in ['*', '/'];
end;



{-------------------------------------------------------}
{ Output a String with Tab }
procedure Emit(s: string);
begin
	Write(TAB, s);
end;



{-------------------------------------------------------}
{ Output a String with Tab and CRLF }
procedure EmitLn(s: string);
begin
	Emit(s);
	WriteLn;
end;



{-------------------------------------------------------}
{ Parse and translate an identifier (either a variable  }
{ or a function call.                                   }
procedure Ident;
var Name: char;
begin
	Name := GetName;
	if Look = '(' then begin
		{ function name, argument parens present }
		Match('(');
		{ currently only empty argument list allowed }
		Match(')');
		EmitLn('BSR ' + Name);
		end
	else
		EmitLn('MOVE ' + Name + '(PC),D0');
end;



{-------------------------------------------------------}
{ parse and translate a math factor }
procedure Expression; Forward;
procedure Factor;
begin
	if Look = '(' then begin
		Match('(');
		Expression;
		Match(')');
		end {then}
	else if IsAlpha(Look) then
		Ident
	else
		EmitLn('MOVE #' + GetNum + ',D0');
end;



{-------------------------------------------------------}
{ recgonize and translate a multiply }
procedure Multiply;
begin
	Match('*');
	Factor;
	EmitLn('MULS (SP)+,D0'); { multiply d0 by tos }
end;



{-------------------------------------------------------}
{ recgonize and translate a divide }
procedure Divide;
begin
	{ i'm sure the divs instruction is wrong as }
	{ regards the order of operands but i am }
	{ leaving it as in the original for now }
	Match('/');
	Factor;
	EmitLn('MOVE (SP)+,D1'); { dividend }
	EmitLn('DIVS D1,D0'); { d0 = d0 / d1, is this correct? }
end;



{-------------------------------------------------------}
{ recognize and translate a math term }
procedure Term;
begin
	Factor;
	while Look in ['*', '/'] do begin
		EmitLn('MOVE D0,-(SP)');
		case Look of
			'*': Multiply;
			'/': Divide;
		else Expected('Mulop');
		end; {case}
	end; {while}
end;



{-------------------------------------------------------}
{ recognize and translate addition }
procedure Add;
begin
	Match('+');
	Term;
	EmitLn('ADD (SP)+,D0'); { add tos to d0 }
end;



{-------------------------------------------------------}
{ recognize and translate subtraction }
procedure Subtract;
begin
	Match('-');
	Term;
	EmitLn('SUB (SP+),D0'); { sub tos from d0 }
	EmitLn('NEG D0');
end;



{-------------------------------------------------------}
{ Parse and translate an expression }
procedure Expression;
begin
	if IsAddop(Look) then
		EmitLn('CLR D0')
	else
		Term;
	while IsAddop(Look) do begin
		EmitLn('MOVE D0,-(SP)'); { push d0 }
		case Look of
			'+': Add;
			'-': Subtract;
		else Expected('Addop');
		end; { case }
	end; { while }
end;



{-------------------------------------------------------}
{ parse and translate an assignment statement           }
procedure Assignment;
var Name: char;
begin
	Name := GetName;
	Match('=');
	Expression;
	EmitLn('LEA ' + Name + '(PC),A0');
	EmitLn('MOVE D0,(A0)');
end;



{-------------------------------------------------------}
{ Initialize }
procedure Init;
begin
	{ prime the lookahead buffer }
	GetChar;
end;


{-------------------------------------------------------}
{ Main Program }
begin
	Init;
	Assignment;
	if not IsLineEnd(Look) then
		Expected('Newline');
end.

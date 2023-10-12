{--------------------------------------------------------------}
program Cradle;

  {--------------------------------------------------------------}
  { Constant Declarations }

const
  TAB = ^I;

  {--------------------------------------------------------------}
  { Variable Declarations }

var
  Look: char;              { Lookahead Character }

  {--------------------------------------------------------------}
  { Read New Character From Input Stream }

  procedure GetChar;
  begin
    Read(Look);
  end;

  {--------------------------------------------------------------}
  { Report an Error }

  procedure Error(s: string);
  begin
    WriteLn;
    WriteLn(^G, 'Error: ', s, '.');
  end;


  {--------------------------------------------------------------}
  { Report Error and Halt }

  procedure Abort(s: string);
  begin
    Error(s);
    Halt;
  end;


  {--------------------------------------------------------------}
  { Report What Was Expected }

  procedure Expected(s: string);
  begin
    Abort(s + ' Expected');
  end;

  {--------------------------------------------------------------}
  { Match a Specific Input Character }

  procedure Match(x: char);
  begin
    if Look = x then GetChar
    else
      Expected('''' + x + '''');
  end;


  {--------------------------------------------------------------}
  { Recognize an Alpha Character }

  function IsAlpha(c: char): boolean;
  begin
    IsAlpha := upcase(c) in ['A'..'Z'];
  end;


  {--------------------------------------------------------------}
  { Recognize a Decimal Digit }

  function IsDigit(c: char): boolean;
  begin
    IsDigit := c in ['0'..'9'];
  end;

  {--------------------------------------------------------------}
  { recognize an addition/subtraction operation }
  function IsAddop(c: char): boolean;
  begin
    IsAddop := c in ['+', '-'];
  end;

  {--------------------------------------------------------------}
  { recognize a multiplication/division operation }
  function IsMulop(c: char): boolean;
  begin
    IsMulop := c in ['*', '/'];
  end;

  {--------------------------------------------------------------}
  { Get an Identifier }

  function GetName: char;
  begin
    if not IsAlpha(Look) then Expected('Name');
    GetName := UpCase(Look);
    GetChar;
  end;


  {--------------------------------------------------------------}
  { Get a Number }

  function GetNum: integer;
  var
    Value: integer;
  begin
    Value := 0;
    if not IsDigit(Look) then Expected('Integer');
    while IsDigit(Look) do
    begin
      Value := 10 * Value + Ord(look) - Ord('0');
      GetChar;
    end;
    GetNum := Value;
  end;


  {--------------------------------------------------------------}
  { Output a String with Tab }

  procedure Emit(s: string);
  begin
    Write(TAB, s);
  end;




  {--------------------------------------------------------------}
  { Output a String with Tab and CRLF }

  procedure EmitLn(s: string);
  begin
    Emit(s);
    WriteLn;
  end;

  {--------------------------------------------------------------}
  { Initialize }

  procedure Init;
  begin
    GetChar;
  end;

  {--------------------------------------------------------------}
  { parse and translate a math factor }
  function Expression: integer; forward;

  function Factor: integer;
  begin
    if Look = '(' then
    begin
      Match('(');
      Factor := Expression;
      Match(')');
    end
    else
      Factor := GetNum;
  end;


  {--------------------------------------------------------------}
  { parse and translate a mathematical term }
  function Term: integer;
  var
    Value: integer;
  begin
    Value := Factor;
    while IsMulop(Look) do
    begin
      case Look of
        '*': begin
          Match('*');
          Value := Value * Factor;
        end;
        '/': begin
          Match('/');
          Value := Value div Factor;
        end;
      end; { case }
    end; { while }
    Term := Value;
  end;

  {--------------------------------------------------------------}
  { parse and translate an expression }
  function Expression: integer;
  var
    Value: integer;
  begin
    if IsAddop(Look) then
      Value := 0
    else
      Value := Term;





    { asdf }
    while IsAddop(look) do
    begin
      case Look of
        '+': begin
          Match('+');
          Value := Value + Term;
        end;
        '-': begin
          Match('-');
          Value := Value - Term;
        end;
      end; { case }
    end; { while }
    Expression := Value;
  end;

  {--------------------------------------------------------------}
  { Main Program }

begin
  Init;
  WriteLn(Expression);
  ReadLn; { this closes expression's reads }
  ReadLn; { this should pause for input and not close the app windows }
end.
{--------------------------------------------------------------}

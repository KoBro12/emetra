﻿unit TestCaseMathParser;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework,
  Bitsoft.MathParser,
  Bitsoft.MathParser.StdFunctions,
  {General classes, utilities}
  Emetra.Logging.Interfaces,
  {Standard}
  System.SysUtils, System.Math;

type
  // Test methods for class TMathParser

  TestTMathParser = class( TTestCase )
  strict private
    fMathParser: TMathParser;
  private
  public
    procedure HandleGetVar( Sender: TObject; AVarName: string; var AValue: Extended; var AFound: Boolean );
    procedure HandleParseError( Sender: TMathParser; const ATokenError: TTokenError );
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInvalidInput;
    procedure TestIsNull;
    procedure TestIsPositive;
    procedure TestSignum;
    procedure TestUnknownVariables;
    procedure TestRounding;
    procedure TestTruncation;
    procedure TestTrigononmetry;
    procedure TestSquareRoot;
    procedure TestNegativeSquareRoot;
    procedure TestDateFunctions;
  end;

implementation

uses
  System.DateUtils;

const
  TXT_SHOULD_BE_ONE       = 'The expression shold evaluate to 1.';
  TXT_SHOULD_BE_ZERO      = 'The expression should evaluate to 0.';
  TXT_SHOULD_BE_MINUS_ONE = 'The expression should evaluate to -1.';
  TXT_SHOULD_BE_INTEGER   = 'The expression should evaluate to %d.';

const
  EPSILON = 0.0001;

{$REGION 'Initialization'}

procedure TestTMathParser.SetUp;
begin
  fMathParser := TMathParser.Create;
  fMathParser.OnGetVar := Self.HandleGetVar;
  fMathParser.OnParseError := Self.HandleParseError;
end;

procedure TestTMathParser.TearDown;
begin
  fMathParser.Free;
end;

{$ENDREGION}

procedure TestTMathParser.HandleGetVar( Sender: TObject; AVarName: string; var AValue: Extended; var AFound: Boolean );
begin
  GlobalLog.Event( LOG_STUB + 'Asked for %s', [ClassName, 'HandleGetVar', AVarName] );
  AValue := 1;
  AFound := true;
end;

procedure TestTMathParser.HandleParseError( Sender: TMathParser; const ATokenError: TTokenError );
begin
  GlobalLog.SilentWarning( LOG_STUB + 'Error = %d, Expession = "%s".', [ClassName, 'HandleParseError', ord( ATokenError ), Sender.LogText] );
end;

procedure TestTMathParser.TestInvalidInput;
begin
  try
    fMathParser.ParseString := 'THIS IS #ONE TEST';
    fMathParser.Parse;
    CheckEquals( true, false, 'This code should never be reached' );
  except
    on E: Exception do
    begin
      GlobalLog.SilentWarning( E.Message );
      CheckEquals( EInvalidArgument.ClassName, E.ClassName );
      CheckEquals( true, true, 'But this code should always be reached' );
    end;
  end;
end;

procedure TestTMathParser.TestIsNull;
begin
  fMathParser.ParseString := 'ISNULL(0)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'ISNULL(1)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
  fMathParser.ParseString := 'ISNULL(-1)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
end;

procedure TestTMathParser.TestIsPositive;
begin
  fMathParser.ParseString := 'ISPOS(0)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
  fMathParser.ParseString := 'ISPOS(1)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'ISPOS(0.01)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'ISPOS(-0.01)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
  fMathParser.ParseString := 'ISPOS(-1)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
end;

procedure TestTMathParser.TestRounding;
begin
  fMathParser.ParseString := 'ROUND(3.49)';
  CheckEquals( 3, fMathParser.Parse );
  fMathParser.ParseString := 'ROUND(3.501)';
  CheckEquals( 4, fMathParser.Parse );
  fMathParser.ParseString := 'ROUND(-3.501)';
  CheckEquals( -4, fMathParser.Parse );
end;

procedure TestTMathParser.TestTrigononmetry;
begin
  fMathParser.ParseString := 'SIN(PI)';
  CheckTrue( SameValue( 0, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'COS(PI)';
  CheckTrue( SameValue( -1, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'SIN(PI/2)';
  CheckTrue( SameValue( 1, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'COS(PI/2)';
  CheckTrue( SameValue( 0, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'SIN(PI/6)';
  CheckTrue( SameValue( 0.5, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'TAN(PI/4)';
  CheckTrue( SameValue( 1, fMathParser.Parse, EPSILON ) );
  fMathParser.ParseString := 'TAN(3*PI/4)';
  CheckTrue( SameValue( -1, fMathParser.Parse, EPSILON ) );
end;

procedure TestTMathParser.TestTruncation;
begin
  fMathParser.ParseString := 'TRUNC(3.49)';
  CheckEquals( 3, fMathParser.Parse );
  fMathParser.ParseString := 'TRUNC(3.501)';
  CheckEquals( 3, fMathParser.Parse );
  fMathParser.ParseString := 'TRUNC(-3.49)';
  CheckEquals( -3, fMathParser.Parse );
  fMathParser.ParseString := 'TRUNC(-3.501)';
  CheckEquals( -3, fMathParser.Parse );
end;

procedure TestTMathParser.TestSignum;
begin
  fMathParser.ParseString := 'SIGN(2)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'SIGN(-1)';
  CheckEquals( -1, fMathParser.Parse, TXT_SHOULD_BE_MINUS_ONE );
  fMathParser.ParseString := 'SIGN(0)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
end;

procedure TestTMathParser.TestSquareRoot;
begin
  fMathParser.ParseString := 'SQRT(16)';
  CheckEquals( 4, fMathParser.Parse );
  fMathParser.ParseString := 'SQRT(9)';
  CheckEquals( 3, fMathParser.Parse );
  fMathParser.ParseString := 'SQRT(6.25)';
  CheckTrue( SameValue( 2.5, fMathParser.Parse, EPSILON ) );
end;

procedure TestTMathParser.TestUnknownVariables;
const
  TEST_EXPR =
  { } '(0.5*(ISNULL(MNA_K1-1) + ' + sLineBreak +
  { } 'ISNULL(MNA_K2-1) + ' + sLineBreak +
  { } 'ISNULL(MNA_K3-1))-0.5) * (1-ISNEG(( ISNULL( MNA_K1-1 ) + ' + sLineBreak +
  { } 'ISNULL(MNA_K2-1) + ISNULL(MNA_K3-1))-0.5))';

begin
  { Unknown variables are retrieved with HandleGetVar }
  fMathParser.ParseString := TEST_EXPR;
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
end;

procedure TestTMathParser.TestDateFunctions;
begin
  { Casing is odd on purpose }
  fMathParser.ParseString := 'YEAROF(NOW)';
  CheckEquals( YearOf( Now ), fMathParser.Parse, Format( TXT_SHOULD_BE_INTEGER, [YearOf( Now )] ) );
  fMathParser.ParseString := 'MonthOf(Now)';
  CheckEquals( MonthOf( Now ), fMathParser.Parse, Format( TXT_SHOULD_BE_INTEGER, [MonthOf( Now )] ) );
  fMathParser.ParseString := 'dAYOf( NOW )';
  CheckEquals( DayOf( Now ), fMathParser.Parse, Format( TXT_SHOULD_BE_INTEGER, [DayOf( Now )] ) );
  fMathParser.ParseString := 'weekOF( now )';
  CheckEquals( WeekOf( Now ), fMathParser.Parse, Format( TXT_SHOULD_BE_INTEGER, [WeekOf( Now )] ) );
end;

procedure TestTMathParser.TestNegativeSquareRoot;
begin
  fMathParser.ParseString := 'SQRT(-1)';
  try
    CheckTrue( SameValue( 2.5, fMathParser.Parse, EPSILON ) );
  except
    on E: Exception do
      CheckEquals( E.ClassName, EInvalidOp.ClassName );
  end;
end;

initialization

// Register any test cases with the test runner
RegisterTest( TestTMathParser.Suite );

end.
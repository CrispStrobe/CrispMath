"""Independent frozen module displays and complete assignment references."""
import re

STATISTICS=[
 ('decreasing-regression','Regression',{'x values':'-2,-1,0,1,2','y values':'9,6,3,0,-3'},
  {'Slope a =':'-3','Intercept b =':'3','R² =':'1','n =':'5'}),
 ('zero-success-binomial','Distributions',{'n (trials)':'12','p (success)':'0.2','k':'0'},
  {'P(X = k)':'0.068719','P(X ≤ k)':'0.068719'}),
 ('translated-eight-sigma','Distributions',{'mean μ':'10','stddev σ':'3','x for CDF':'-14'},
  {'CDF(x) = P(X ≤ x)':'6.2210e-16'}),
 ('positive-cauchy-interval','Distributions',{'Degrees of freedom ν':'1','Interval lower bound':'0','Interval upper bound':'1.7320508075688772'},
  {'P(lower ≤ T ≤ upper)':'0.333333'}),
 ('three-bin-chi-square','Tests',{'Observed counts':'4,8,12','Expected counts':'8,8,8'},
  {'χ² statistic':'4','Degrees of freedom':'2','p-value (upper tail)':'0.135335'}),
 ('eighth-full-precision','Descriptive',{'Data (comma, space, or newline-separated)':'0.125,0.25,0.375'},
  {'Mean':0.25,'Median':0.25,'Sample standard deviation':0.125}),
 ('trillion-full-precision','Descriptive',{'Data (comma, space, or newline-separated)':'1000000000000,1000000000001,1000000000002'},
  {'Mean':1000000000001.0,'Median':1000000000001.0,'Sample standard deviation':1.0}),
]
ENUMERATIONS=[
 ('negative-circle','vars: x, y in -4..4\nx*x+y*y == 10\nx < 0',
  [{'x':-3,'y':-1},{'x':-3,'y':1},{'x':-1,'y':-3},{'x':-1,'y':3}]),
 ('ordered-triple','vars: x, y, z in 0..6\nx+y+z == 6\nx < y\ny < z',
  [{'x':0,'y':1,'z':5},{'x':0,'y':2,'z':4},{'x':1,'y':2,'z':3}]),
 ('negative-excluded-root','vars: x in -5..5\nx*x == 9\nx != 3',[{'x':-3}]),
]
NUMBER=r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?'


def validate_full_precision(text,expected):
    """Consume the complete dialog text, retaining every double value."""
    pattern=r'\s*'+r'\s+'.join(re.escape(label)+r':\s*('+NUMBER+r')'for label in expected)+r'\s*'
    match=re.fullmatch(pattern,text)
    assert match,(text,expected)
    values=dict(zip(expected,match.groups()))
    assert all(float(values[label])==value for label,value in expected.items()),(text,expected)
    return values


def validate_enumeration(text,expected):
    """Compare the entire numbered assignment list, never just its first row."""
    lines=text.strip().splitlines();assert len(lines)==len(expected),(text,expected)
    found=[]
    for index,line in enumerate(lines,1):
        match=re.fullmatch(r'\s*(\d+)\.\s*(.+)',line)
        assert match and int(match[1])==index,(text,index)
        row={}
        for part in match[2].split(','):
            pair=re.fullmatch(r'\s*([xyz])\s*=\s*(-?\d+)\s*',part)
            assert pair and pair[1]not in row,text
            row[pair[1]]=int(pair[2])
        found.append(row)
    keys=lambda row:tuple(sorted(row.items()))
    assert len({keys(row)for row in found})==len(found),text
    assert {keys(row)for row in found}=={keys(row)for row in expected},(text,expected)
    return found


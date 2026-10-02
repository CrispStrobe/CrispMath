"""Independent SymPy/SciPy reference answers for the separately drafted 50 tasks.

This script never imports the app or reads its output. References are committed;
normal application tests need neither SymPy nor SciPy.
"""
import itertools
import json
import math
from datetime import date, timedelta
from pathlib import Path
import sympy as s
from scipy import stats
x=s.symbols('x'); tasks=[]
def engine(n,title,op,args,expected,**extra):
 tasks.append(dict(id=f'fresh-{n:02}',kind='engine',title=title,operation=op,args=args,expected=str(expected).replace('**','^'),**extra))
def module(index,title,op,expected,**args):
 tasks.append(dict(id=f'fresh-{index:02}',kind='module',title=title,operation=op,expected=expected,**args))
engine(1,'Tax then discount','evaluate',['37.50*1.19*0.90'],s.Rational(375,10)*s.Rational(119,100)*s.Rational(9,10))
engine(2,'Rational addition','evaluate',['7/12+5/18'],s.Rational(7,12)+s.Rational(5,18))
engine(3,'Integer remainder','evaluate',['123456789%97'],123456789%97,exact=True)
module(4,'Prime factorization','calculator','2³ · 3² · 5 · 7 · 11 · 13',expression='factorint(360360)')
module(5,'GCD and LCM','chain',[str(s.gcd(84,126)),str(s.lcm(84,126))],steps=[{'operation':op,'args':['84','126']}for op in ['gcd','lcm']])
engine(6,'Exact large integer','evaluate',['2^100'],2**100,exact=True)
engine(7,'Combinations','evaluate',['20!/(6!*14!)'],s.binomial(20,6))
engine(8,'Exact trigonometry','evaluate',['sin(pi/6)+cos(pi/3)'],s.sin(s.pi/6)+s.cos(s.pi/3))
engine(9,'Logarithm base two','evaluate',['log(1024)/log(2)'],10)
engine(10,'Complex magnitude','evaluate',['abs(3+4*I)'],5)
engine(11,'Fourth power expansion','expand',['(2*x-3)^4'],s.expand((2*x-3)**4),resultPattern=r'x\^4')
engine(12,'Quartic factorization','factor',['x^4-5*x^2+4'],s.factor(x**4-5*x**2+4),resultPattern=r'\(')
module(13,'Cancellation retains excluded inputs','rationalDomain',{'value':str(s.cancel((x**2-9)/(x**2+x-6))).replace('**','^'),'excluded':sorted(map(str,s.solve(x**2+x-6,x)))},expression='(x^2-9)/(x^2+x-6)',variable='x')
engine(14,'Quadratic roots','solve',['x^2-5*x+6','x'],'x = {2, 3}')
engine(15,'Two equation linear system','linsolve',['2*x+3*y-7;4*x-y-5','x,y'],'x = 11/7, y = 9/7')
engine(16,'Complex quadratic roots','solve',['x^2+1','x'],'x = {-I, I}')
engine(17,'Product rule','differentiate',['x^3*exp(x)','x'],s.diff(x**3*s.exp(x),x))
module(18,'Second derivative','chain',[str(s.diff(s.sin(2*x),x)).replace('**','^'),str(s.diff(s.sin(2*x),x,2)).replace('**','^')],steps=[{'operation':'differentiate','args':['sin(2*x)','x']},{'operation':'differentiate','args':['@previous','x']}])
engine(19,'Indefinite polynomial integral','integrate',['3*x^2-4*x+2','x'],str(s.integrate(3*x**2-4*x+2,x))+'+C')
engine(20,'Signed definite polynomial integral','integrate',['x^3','x','-2','3'],s.integrate(x**3,(x,-2,3)))
engine(21,'Definite sine integral','integrate',['sin(x)','x','0','pi'],s.integrate(s.sin(x),(x,0,s.pi)))
engine(22,'Removable trigonometric limit','limit',['sin(3*x)/x','x','0'],s.limit(s.sin(3*x)/x,x,0))
engine(23,'Radical limit','limit',['(sqrt(1+x)-1)/x','x','0'],s.limit((s.sqrt(1+x)-1)/x,x,0))
engine(24,'Fifth degree exponential series','series',['exp(x)','x','0','6'],s.series(s.exp(x),x,0,6).removeO())
engine(25,'Logarithm series around one','series',['log(x)','x','1','5'],s.series(s.log(x),x,1,5).removeO())
module(26,'Parabola roots and minimum','chain',['x = {1, 3}','2*x - 4','x = 2','-1'],steps=[{'operation':'solve','args':['x^2-4*x+3','x']},{'operation':'differentiate','args':['x^2-4*x+3','x']},{'operation':'solve','args':['@previous','x']},{'operation':'evaluate','args':['2^2-4*2+3']}])
module(27,'Table with a pole','table',[[v,None if v==1 else 1/(v-1)]for v in [-1,0,1,2,3]],expression='1/(x-1)',xs=[-1,0,1,2,3])
module(28,'Sine cosine intersection','table',[[math.pi/4,0]],expression='sin(x)-cos(x)',xs=[math.pi/4])
for n,title,lines,expected,extra in [(29,'Parameter change recalculates',['a=2','f(t)=t^2+a','f(3)'],['5','t^2+5','14'],{'edit':{'index':0,'source':'a=5'}}),(30,'Nested worksheet functions',['f(t)=t^2','g(t)=f(t)+f(t+1)','g(3)'],['t^2','t^2+(t+1)^2','25'],{})]:tasks.append(dict(id=f'fresh-{n:02}',kind='document',title=title,lines=lines,expected=expected,**extra))
engine(31,'Three by three determinant','evaluate',['det(Matrix([[2,1,3],[0,-1,4],[5,2,0]]))'],s.Matrix([[2,1,3],[0,-1,4],[5,2,0]]).det())
module(32,'Inverse and identity product','chain',['Matrix([[3/5,-7/10],[-1/5,2/5]])','Matrix([[1,0],[0,1]])'],steps=[{'operation':'evaluate','args':['inv(Matrix([[4,7],[2,6]]))']},{'operation':'evaluate','args':['Matrix([[4,7],[2,6]])*@previous']}])
engine(33,'Rank deficient RREF','evaluate',['rref(Matrix([[1,2,3],[2,4,6],[1,1,1]]))'],'Matrix([[1,0,-1],[0,1,2],[0,0,0]])')
engine(34,'Symmetric eigenvalues','evaluate',['eigenvalues(Matrix([[2,1],[1,2]]))'],'{1,3}')
data=[2,4,4,4,5,5,7,9];module(35,'Sample descriptive statistics','describe',{'mean':sum(data)/len(data),'median':float(stats.scoreatpercentile(data,50)),'sampleStddev':float(s.sqrt(s.Rational(sum((v-5)**2 for v in data),7)))},data=data)
module(36,'Exact linear regression','regression',{'slope':2,'intercept':1,'rSquared':1},xs=[1,2,3,4],ys=[3,5,7,9])
r=stats.ttest_1samp([9,10,11,10,10],10);module(37,'Two sided one sample t test','oneSampleT',{'statistic':float(r.statistic),'df':4,'pValue':float(r.pvalue)},data=[9,10,11,10,10],mean=10)
before=[10,12,9,11,13];after=[12,13,12,12,16];r=stats.ttest_rel(before,after);module(38,'Paired improvement t test','pairedT',{'statistic':float(r.statistic),'df':4,'pValue':float(r.pvalue)},before=before,after=after)
r=stats.chisquare([10,20,30],[20,20,20]);module(39,'Chi square goodness of fit','chiSquare',{'statistic':float(r.statistic),'df':2,'pValue':float(r.pvalue)},observed=[10,20,30],counts=[20,20,20])
module(40,'Binomial probability','binomial',float(stats.binom.pmf(3,10,.2)),n=10,p=.2,k=3)
for n,title,expression,answer in [(41,'Speed conversion','72 km/h in m/s','20 m/s'),(42,'Temperature conversion','32 °F in °C','0 °C'),(43,'Mixed length addition','2 m + 35 cm in m','2.35 m'),(44,'Kinetic energy dimensions','0.5 * 3 kg * 4 m/s * 4 m/s in J','24 J'),(45,'Volume conversion','2 L in cm^3','2000 cm³')]:module(n,title,'unit',answer,expression=expression)
module(46,'Leap day arithmetic','date',str(date(2028,2,28)+timedelta(days=2)),expression='2028-02-28 + 2 days')
module(47,'Leap year day difference','date',f'{(date(2028,3,1)-date(2027,12,31)).days} days',expression='days between 2027-12-31 and 2028-03-01')
queens=[dict(zip(['q1','q2','q3','q4'],p))for p in itertools.permutations(range(1,5))if all(abs(p[i]-p[j])!=j-i for i in range(4)for j in range(i+1,4))]
program='vars: q1, q2, q3, q4 in 1..4\nallDifferent(q1,q2,q3,q4)\n'+'\n'.join(f'q{i+1} - q{j+1} != {d}'for i in range(4)for j in range(i+1,4)for d in [j-i,i-j])
module(48,'Four queens complete solutions','constraint',queens,program=program,unordered=True)
sat=[dict(zip(['a','b','c'],p))for p in itertools.product([0,1],repeat=3)if (p[0]or p[1])and(not p[0]or p[2])and(not p[1]or not p[2])]
module(49,'Three clause SAT','constraint',sat,program='vars: a, b, c in 0..1\na + b >= 1\nc - a >= 0\nb + c <= 1',unordered=True)
givens=[[1,0,0,4],[0,4,1,0],[0,1,4,0],[4,0,0,1]];solutions=[]
def solve(grid,pos=0):
 if pos==16:solutions.append({f'r{i+1}c{j+1}':grid[i][j]for i in range(4)for j in range(4)});return
 i,j=divmod(pos,4)
 if givens[i][j]:solve(grid,pos+1);return
 for v in range(1,5):
  if v in grid[i]or any(row[j]==v for row in grid)or any(grid[r][c]==v for r in range(i//2*2,i//2*2+2)for c in range(j//2*2,j//2*2+2)):continue
  grid[i][j]=v;solve(grid,pos+1);grid[i][j]=0
solve([row[:]for row in givens]);names=[[f'r{i+1}c{j+1}'for j in range(4)]for i in range(4)];groups=names+list(map(list,zip(*names)))+[[names[i][j]for i in range(r,r+2)for j in range(c,c+2)]for r in [0,2]for c in [0,2]]
program='vars: '+', '.join(sum(names,[]))+' in 1..4\n'+'\n'.join('allDifferent('+','.join(group)+')'for group in groups)+'\n'+'\n'.join(f'{names[i][j]} == {givens[i][j]}'for i in range(4)for j in range(4)if givens[i][j])
module(50,'Four by four Sudoku complete solutions','constraint',solutions,program=program,unordered=True)
assert len(tasks)==50
Path('test/fixtures/fresh_workflow_tasks.json').write_text(json.dumps({'schemaVersion':1,'reference':'Independent SymPy/SciPy, Gregorian datetime and exhaustive Python constraint enumeration; drafted before inspecting app support.','tasks':tasks},indent=2)+'\n')

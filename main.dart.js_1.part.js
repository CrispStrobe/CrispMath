((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,C,B={
cwl(){var w=$.dc()
return new B.QN(w.fy,w.id,w.go)},
QN:function QN(d,e,f){this.a=d
this.b=e
this.c=f},
QO:function QO(){},
QM:function QM(d){this.a=d},
ak6:function ak6(d,e){this.a=d
this.b=e
this.c=null},
be3:function be3(d,e){this.a=d
this.b=e},
be5:function be5(d,e,f,g,h){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h},
be4:function be4(d){this.a=d},
cwk(){return new B.yl(null)},
yl:function yl(d){this.a=d},
a0c:function a0c(d,e){var _=this
_.d=$
_.e=d
_.f=e
_.w=_.r=!1
_.x=0
_.c=_.a=_.z=_.y=null},
buq:function buq(d){this.a=d},
bur:function bur(d,e){this.a=d
this.b=e},
bus:function bus(d,e){this.a=d
this.b=e},
but:function but(d,e){this.a=d
this.b=e},
buu:function buu(d){this.a=d},
buv:function buv(d){this.a=d},
buw:function buw(d,e){this.a=d
this.b=e},
cxp(){var w=A.cb9()
return w==null?new A.II(A.a([],x.W)):w}},D
J=c[1]
A=c[0]
C=c[2]
B=a.updateHolder(c[3],B)
D=c[4]
B.QN.prototype={
ga9X(){var w=A.a_s(this.a)
return w!=null&&C.f.m(A.a(["http","https"],x.s),w.ghg())&&w.gnL().length!==0&&C.e.u(this.b).length!==0}}
B.QO.prototype={
j(d){return"Request cancelled"},
$ibg:1}
B.QM.prototype={
j(d){return this.a},
$ibg:1}
B.ak6.prototype={
aX(){var w=this.c
return w==null?null:w.$0()},
a0f(d){return this.bpg(d)},
bpg(d){var w=0,v=A.D(x.N),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g,f
var $async$a0f=A.y(function(e,a0){if(e===1){s.push(a0)
w=t}for(;;)switch(w){case 0:f=q.a.$0()
if(!f.ga9X())throw A.c(A.an("Configure the provider endpoint and model in CrispAssist settings."))
l=C.e.u(d)
if(l.length===0)throw A.c(A.a5("Enter a math question.",null))
q.aX()
p=q.b.$0()
o=new A.bp(new A.aw($.aL,x.I),x.X)
n=new B.be3(o,p)
q.c=n
k=C.e.bF(A.fH(f.a,0,null).gj_(),"/messages")
j=x.N
i=A.r(j,j)
i.k(0,"Content-Type","application/json")
if(f.c.length!==0&&!k)i.k(0,"Authorization","Bearer "+f.c)
if(k)i.k(0,"anthropic-version","2023-06-01")
if(k&&f.c.length!==0)i.k(0,"x-api-key",f.c)
h=A.r(j,x.z)
h.k(0,"model",f.b)
h.k(0,"max_tokens",512)
if(k)h.k(0,"system",y.d)
g=A.a([],x.m)
if(!k)g.push(A.a0(["role","system","content",y.d],j,j))
g.push(A.a0(["role","user","content",l],j,j))
h.k(0,"messages",g)
m=new B.be5(p,f,i,h,k)
t=3
l=A.cB_(A.a([m.$0(),o.a],x.Z),j)
f.toString
w=6
return A.q(l.ae6(D.aYH,new B.be4(p)),$async$a0f)
case 6:l=a0
u=l
r=[1]
w=4
break
r.push(5)
w=4
break
case 3:r=[2]
case 4:t=2
l=q.c
j=n
if(l==null?j==null:l===j)q.c=null
p.bj()
w=r.pop()
break
case 5:case 1:return A.B(u,v)
case 2:return A.A(s.at(-1),v)}})
return A.C($async$a0f,v)}}
B.yl.prototype={
af(){var w=$.ag()
return new B.a0c(new A.aN(C.e0,w),new A.aN(C.e0,w))}}
B.a0c.prototype={
ga7M(){var w,v=this.d
if(v===$){this.a.toString
w=new B.ak6(B.cSl(),B.cSY())
v=this.d=w}return v},
n(){var w,v,u=this;++u.x
u.ga7M().aX()
w=u.e
v=$.ag()
w.a6$=v
w.a3$=0
w=u.f
w.a6$=v
w.a3$=0
u.aG()},
T0(){var w=0,v=A.D(x.H),u=1,t=[],s=[],r=this,q,p,o,n,m,l,k
var $async$T0=A.y(function(d,e){if(d===1){t.push(e)
w=u}for(;;)switch(w){case 0:l=++r.x
r.E(new B.buq(r))
u=3
w=6
return A.q(r.ga7M().a0f(r.e.a.a),$async$T0)
case 6:q=e
if(r.c!=null&&J.i(l,r.x))r.E(new B.bur(r,q))
s.push(5)
w=4
break
case 3:u=2
k=t.pop()
m=A.a3(k)
if(m instanceof B.QM){p=m
if(r.c!=null&&J.i(l,r.x))r.E(new B.bus(r,p))}else{o=m
if(r.c!=null&&J.i(l,r.x))r.E(new B.but(r,o))}s.push(5)
w=4
break
case 2:s=[1]
case 4:u=1
if(r.c!=null&&J.i(l,r.x))r.E(new B.buu(r))
w=s.pop()
break
case 5:return A.B(null,v)
case 1:return A.A(t.at(-1),v)}})
return A.C($async$T0,v)},
J(d){var w=this,v=null,u=w.ga7M(),t=u.a.$0(),s=new A.B8(d.ae(x.w).r.f.geO()),r=A.o(s.fL(C.rG),v,v,v,v,v,v,v,v),q=A.o(t.ga9X()?s.LB(C.rH,t.b):s.fL(C.rI),v,v,v,v,v,v,v,v),p=w.r,o=s.fL(C.rJ),n=x.p
p=A.a([q,C.a8,A.cy(v,C.x,!1,v,!0,C.J,v,A.cC(),w.e,v,v,v,v,v,2,A.cX(v,v,v,v,v,v,v,v,!0,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,s.fL(C.rK),v,v,v,v,v,v,v,v,o,!0,!0,!1,v,v,v,v,v,v,v,v,v,v,v,v,v,v),C.O,!0,v,!0,!p,!1,v,C.av,v,v,v,v,v,v,v,v,v,4,2,v,!1,"\u2022",v,v,v,v,v,!1,v,v,!1,v,!0,v,C.ay,v,v,v,v,v,v,v,v,v,v,v,v,!0,C.a1,v,C.az,v,v,v,v),C.a8,A.o(s.fL(C.rL),v,v,v,v,v,v,v,v)],n)
if(w.r)p.push(D.czU)
q=w.z
if(q!=null)p.push(new A.ap(D.P_,A.bX(v,v,v,A.o(s.LB(C.rT,q),v,v,v,v,v,v,v,v),!1,v,v,v,!1,v,!1,v,v,v,v,v,v,v,v,v,v,!0,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,C.a6,v),v))
q=w.y
if(q!=null)p.push(new A.ap(D.P_,A.bX(v,v,v,A.o(q,v,v,v,v,v,A.bf(v,v,A.H(d).ax.fy,v,v,v,v,v,v,v,v,v,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v),!1,v,v,v,!1,v,!1,v,v,v,v,v,v,v,v,v,v,!0,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,C.a6,v),v))
if(w.w)C.f.B(p,A.a([C.a8,A.o(s.fL(C.rN),v,v,v,v,v,v,v,v),A.cy(v,C.x,!1,v,!0,C.J,v,A.cC(),w.f,v,v,v,v,v,2,A.cX(v,v,v,v,v,v,v,v,!0,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,s.fL(C.rO),!0,!0,!1,v,v,v,v,v,v,v,v,v,v,v,v,v,v),C.O,!0,v,!0,v,!1,v,C.av,v,v,v,v,v,v,v,v,v,3,1,v,!1,"\u2022",v,v,v,v,v,!1,v,v,!1,v,!0,v,C.ay,v,v,v,v,v,v,v,v,v,v,v,v,!0,C.a1,v,C.az,v,v,v,v)],n))
q=A.bv(A.ee(A.at(p,C.b1,C.v,C.a7),v,C.O,v,v,!1,C.aa),v,520)
n=A.a([A.bU(A.o(s.fL(C.lX),v,v,v,v,v,v,v,v),v,v,new B.buv(d),v,v)],n)
if(w.r)n.push(A.bU(A.o(s.fL(C.rP),v,v,v,v,v,v,v,v),v,v,u.gfE(),v,v))
if(!w.r){u=t.ga9X()?w.gbav():v
n.push(A.hj(A.o(s.fL(w.y==null?C.rR:C.oj),v,v,v,v,v,v,v,v),u,v))}if(w.w&&!w.r)n.push(A.hj(A.o(s.fL(C.rS),v,v,v,v,v,v,v,v),new B.buw(w,d),v))
return A.dj(n,q,!1,r)}}
var z=a.updateTypes(["~()","av<~>()","QN()","CM()"])
B.be3.prototype={
$0(){var w=this.a
if((w.a.a&30)===0)w.jG(new B.QO())
this.b.bj()},
$S:0}
B.be5.prototype={
$0(){var w=0,v=A.D(x.N),u,t=this,s,r,q,p,o,n,m,l,k,j
var $async$$0=A.y(function(d,e){if(d===1)return A.A(e,v)
for(;;)switch(w){case 0:w=3
return A.q(t.a.u8("POST",A.fH(t.b.a,0,null),t.c,C.as.f9(t.d,null),null),$async$$0)
case 3:k=e
j=k.b
if(j<200||j>=300)throw A.c(A.an("Provider request failed (HTTP "+j+"). Check endpoint, credentials and model."))
s=C.as.fs(A.p1(A.oZ(k.e)).d1(k.w),null)
j=x.f
if(!j.b(s))throw A.c(D.b04)
r=t.e
q=s.h(0,r?"content":"choices")
if(x.j.b(q)){p=J.ar(q)
p=p.ga_(q)||!j.b(p.gW(q))}else p=!0
if(p)throw A.c(D.PV)
o=j.a(J.p5(q))
if(!(!r&&J.i(o.h(0,"finish_reason"),"length")))p=r&&J.i(s.h(0,"stop_reason"),"max_tokens")
else p=!0
if(p)throw A.c(D.b_V)
n=o.h(0,"message")
if(r)m=o.h(0,"text")
else m=j.b(n)?n.h(0,"content"):null
if(typeof m!="string"||C.e.u(m).length===0)throw A.c(D.PV)
l=C.e.u(m)
j=A.v("</?think>",!1,!1,!1)
if(j.b.test(l))throw A.c(D.b_P)
if(C.e.U(l,"```"))l=C.e.u(C.e.fX(C.e.fX(l,A.v("^```[^\\n]*\\n",!0,!1,!1),""),A.v("\\n?```$",!0,!1,!1),""))
j=l.length
if(j===0||j>4000)throw A.c(D.b02)
if(!C.e.U(l,"CLARIFY:"))if(C.e.bF(l,"?")){j=A.v("^(what|which|how|please|can|could|provide|specify)\\b",!1,!1,!1)
j=j.b.test(l)}else j=!1
else j=!0
if(j)throw A.c(new B.QM(C.e.fX(l,A.v("^CLARIFY:\\s*",!0,!1,!1),"")))
u=l
w=1
break
case 1:return A.B(u,v)}})
return A.C($async$$0,v)},
$S:91}
B.be4.prototype={
$0(){this.a.bj()
throw A.c(A.ckp("Provider timed out. Retry or change the endpoint.",null))},
$S:413}
B.buq.prototype={
$0(){var w=this.a
w.r=!0
w.z=w.y=null
w.w=!1},
$S:0}
B.bur.prototype={
$0(){var w=this.a
w.f.sdK(this.b)
w.w=!0},
$S:0}
B.bus.prototype={
$0(){return this.a.z=this.b.a},
$S:0}
B.but.prototype={
$0(){var w=this.a,v=this.b
return w.y=v instanceof B.QO?new A.B8(w.c.ae(x.w).r.f.geO()).fL(C.rQ):J.cI(v)},
$S:0}
B.buu.prototype={
$0(){return this.a.r=!1},
$S:0}
B.buv.prototype={
$0(){A.ao(this.a,!1).de(null)
return null},
$S:0}
B.buw.prototype={
$0(){var w,v=C.e.u(this.a.f.a.a)
if(v.length===0)return
w=$.dc()
w.p4=v
w.dZ(A.bw([C.fu],x.O))
A.ao(this.b,!1).de(null)},
$S:0};(function installTearOffs(){var w=a._static_0,v=a._instance_0u
w(B,"cSl","cwl",2)
v(B.ak6.prototype,"gfE","aX",0)
v(B.a0c.prototype,"gbav","T0",1)
w(B,"cSY","cxp",3)})();(function inheritance(){var w=a.inheritMany,v=a.inherit
w(A.a_,[B.QN,B.QO,B.QM,B.ak6])
w(A.S7,[B.be3,B.be5,B.be4,B.buq,B.bur,B.bus,B.but,B.buu,B.buv,B.buw])
v(B.yl,A.a4)
v(B.a0c,A.a9)})()
A.cml(b.typeUniverse,JSON.parse('{"QO":{"bg":[]},"QM":{"bg":[]},"yl":{"a4":[],"j":[]},"a0c":{"a9":["yl"]}}'))
var y={d:"Translate the user request into ONE CrispMath CAS expression. Return only the expression, without prose or Markdown. Do not compute its result. Syntax: + - * / ^, sin(x), cos(x), sqrt(x), log(x), integrate(expression,x), diff(expression,x), solve(equation,x). If the request is ambiguous, return CLARIFY: followed by the missing information question instead of inventing an expression."}
var x=(function rtii(){var w=A.a6
return{O:w("nU"),Z:w("E<av<h>>"),W:w("E<ci>"),m:w("E<aq<h,h>>"),s:w("E<h>"),p:w("E<j>"),j:w("G<@>"),f:w("aq<@,@>"),N:w("h"),X:w("bp<h>"),I:w("aw<h>"),w:w("OV"),z:w("@"),H:w("~")}})();(function constants(){D.aYH=new A.c_(45e6)
D.P_=new A.aI(0,12,0,12)
D.b_P=new A.bS("Provider returned reasoning instead of an expression. Use a model that returns a final answer within the request limit.",null,null)
D.b_V=new A.bS("Provider response was truncated. Retry with a shorter request or a different model.",null,null)
D.b02=new A.bS("Provider returned an invalid expression.",null,null)
D.b04=new A.bS("Invalid provider response.",null,null)
D.PV=new A.bS("Provider returned no expression.",null,null)
D.czU=new A.ap(C.bk,C.pF,null)})()};
(a=>{a["/y5PDLKga3Hlb7U7RkMVd38SNdk="]=a.current})($__dart_deferred_initializers__);
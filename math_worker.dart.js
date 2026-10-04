(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.tZ(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a,b){if(b!=null)A.d(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.lT(b)
return new s(c,this)}:function(){if(s===null)s=A.lT(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.lT(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
m_(a,b,c,d){return{i:a,p:b,e:c,x:d}},
kC(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.lX==null){A.tr()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.c(A.n2("Return interceptor for "+A.r(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.jF
if(o==null)o=$.jF=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.tx(a)
if(p!=null)return p
if(typeof a=="function")return B.hA
s=Object.getPrototypeOf(a)
if(s==null)return B.Y
if(s===Object.prototype)return B.Y
if(typeof q=="function"){o=$.jF
if(o==null)o=$.jF=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.H,enumerable:false,writable:true,configurable:true})
return B.H}return B.H},
p1(a,b){if(a<0||a>4294967295)throw A.c(A.aw(a,0,4294967295,"length",null))
return J.p2(new Array(a),b)},
ml(a,b){if(a<0)throw A.c(A.aG("Length must be a non-negative integer: "+a,null))
return A.d(new Array(a),b.h("F<0>"))},
bg(a,b){if(a<0)throw A.c(A.aG("Length must be a non-negative integer: "+a,null))
return A.d(new Array(a),b.h("F<0>"))},
p2(a,b){var s=A.d(a,b.h("F<0>"))
s.$flags=1
return s},
p3(a,b){var s=t.e8
return J.oA(s.a(a),s.a(b))},
mm(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
mn(a,b){var s,r
for(s=a.length;b<s;){r=a.charCodeAt(b)
if(r!==32&&r!==13&&!J.mm(r))break;++b}return b},
mo(a,b){var s,r,q
for(s=a.length;b>0;b=r){r=b-1
if(!(r<s))return A.a(a,r)
q=a.charCodeAt(r)
if(q!==32&&q!==13&&!J.mm(q))break}return b},
cz(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.cH.prototype
return J.df.prototype}if(typeof a=="string")return J.bT.prototype
if(a==null)return J.de.prototype
if(typeof a=="boolean")return J.eC.prototype
if(Array.isArray(a))return J.F.prototype
if(typeof a!="object"){if(typeof a=="function")return J.by.prototype
if(typeof a=="symbol")return J.cJ.prototype
if(typeof a=="bigint")return J.cI.prototype
return a}if(a instanceof A.z)return a
return J.kC(a)},
aj(a){if(typeof a=="string")return J.bT.prototype
if(a==null)return a
if(Array.isArray(a))return J.F.prototype
if(typeof a!="object"){if(typeof a=="function")return J.by.prototype
if(typeof a=="symbol")return J.cJ.prototype
if(typeof a=="bigint")return J.cI.prototype
return a}if(a instanceof A.z)return a
return J.kC(a)},
ar(a){if(a==null)return a
if(Array.isArray(a))return J.F.prototype
if(typeof a!="object"){if(typeof a=="function")return J.by.prototype
if(typeof a=="symbol")return J.cJ.prototype
if(typeof a=="bigint")return J.cI.prototype
return a}if(a instanceof A.z)return a
return J.kC(a)},
lV(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.cH.prototype
return J.df.prototype}if(a==null)return a
if(!(a instanceof A.z))return J.bH.prototype
return a},
tm(a){if(typeof a=="number")return J.c9.prototype
if(a==null)return a
if(!(a instanceof A.z))return J.bH.prototype
return a},
lW(a){if(typeof a=="number")return J.c9.prototype
if(typeof a=="string")return J.bT.prototype
if(a==null)return a
if(!(a instanceof A.z))return J.bH.prototype
return a},
ef(a){if(typeof a=="string")return J.bT.prototype
if(a==null)return a
if(!(a instanceof A.z))return J.bH.prototype
return a},
tn(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.by.prototype
if(typeof a=="symbol")return J.cJ.prototype
if(typeof a=="bigint")return J.cI.prototype
return a}if(a instanceof A.z)return a
return J.kC(a)},
oy(a,b){if(typeof a=="number"&&typeof b=="number")return a+b
return J.lW(a).A(a,b)},
N(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.cz(a).I(a,b)},
m6(a,b){if(typeof a=="number"&&typeof b=="number")return a*b
return J.lW(a).i(a,b)},
kY(a){if(typeof a=="number")return-a
return J.lV(a).n(a)},
oz(a,b){if(typeof a=="number"&&typeof b=="number")return a-b
return J.tm(a).G(a,b)},
aL(a,b){if(typeof b==="number")if(Array.isArray(a)||typeof a=="string"||A.tu(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.aj(a).m(a,b)},
m7(a,b,c){return J.ar(a).u(a,b,c)},
d6(a){if(typeof a==="number")return Math.abs(a)
return J.lV(a).dO(a)},
fo(a,b){return J.ar(a).l(a,b)},
m8(a,b){return J.ef(a).am(a,b)},
ek(a,b){return J.ar(a).X(a,b)},
m9(a){return J.tn(a).ct(a)},
ma(a,b){return J.ar(a).bj(a,b)},
oA(a,b){return J.lW(a).j(a,b)},
aV(a,b){return J.aj(a).J(a,b)},
kZ(a,b){return J.ar(a).a0(a,b)},
mb(a,b){return J.ef(a).T(a,b)},
oB(a,b){return J.ar(a).az(a,b)},
oC(a){return J.ar(a).gP(a)},
aM(a){return J.cz(a).gU(a)},
oD(a){return J.aj(a).gO(a)},
oE(a){return J.aj(a).gZ(a)},
bu(a){return J.ar(a).gC(a)},
l_(a){return J.ar(a).gR(a)},
S(a){return J.aj(a).gB(a)},
oF(a){return J.cz(a).ga4(a)},
aN(a){if(typeof a==="number")return a>0?1:a<0?-1:a
return J.lV(a).gE(a)},
mc(a){return J.ar(a).gaD(a)},
oG(a,b){return J.ar(a).bn(a,b)},
l0(a,b){return J.ar(a).H(a,b)},
d7(a,b,c){return J.ar(a).ap(a,b,c)},
b1(a,b){return J.ef(a).v(a,b)},
md(a,b,c){return J.ef(a).F(a,b,c)},
oH(a,b){return J.ar(a).N(a,b)},
b2(a){return J.cz(a).k(a)},
bv(a){return J.ef(a).p(a)},
eA:function eA(){},
eC:function eC(){},
de:function de(){},
a4:function a4(){},
bU:function bU(){},
eO:function eO(){},
bH:function bH(){},
by:function by(){},
cI:function cI(){},
cJ:function cJ(){},
F:function F(a){this.$ti=a},
eB:function eB(){},
hd:function hd(a){this.$ti=a},
d8:function d8(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
c9:function c9(){},
cH:function cH(){},
df:function df(){},
bT:function bT(){}},A={l7:function l7(){},
fJ(a,b,c){if(t.gw.b(a))return new A.dN(a,b.h("@<0>").L(c).h("dN<1,2>"))
return new A.c3(a,b.h("@<0>").L(c).h("c3<1,2>"))},
bE(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
j5(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
ee(a,b,c){return a},
lZ(a){var s,r
for(s=$.aT.length,r=0;r<s;++r)if(a===$.aT[r])return!0
return!1},
eW(a,b,c,d){A.eQ(b,"start")
if(c!=null){A.eQ(c,"end")
if(b>c)A.x(A.aw(b,0,c,"start",null))}return new A.dF(a,b,c,d.h("dF<0>"))},
dl(a,b,c,d){if(t.gw.b(a))return new A.c6(a,b,c.h("@<0>").L(d).h("c6<1,2>"))
return new A.bz(a,b,c.h("@<0>").L(d).h("bz<1,2>"))},
n0(a,b,c){A.oI(b,"takeCount",t.p)},
aY(){return new A.cP("No element")},
mk(){return new A.cP("Too many elements")},
bY:function bY(){},
d9:function d9(a,b){this.a=a
this.$ti=b},
c3:function c3(a,b){this.a=a
this.$ti=b},
dN:function dN(a,b){this.a=a
this.$ti=b},
dM:function dM(){},
bx:function bx(a,b){this.a=a
this.$ti=b},
c4:function c4(a,b){this.a=a
this.$ti=b},
fL:function fL(a,b){this.a=a
this.b=b},
fK:function fK(a){this.a=a},
di:function di(a){this.a=a},
iC:function iC(){},
y:function y(){},
D:function D(){},
dF:function dF(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
b6:function b6(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bz:function bz(a,b,c){this.a=a
this.b=b
this.$ti=c},
c6:function c6(a,b,c){this.a=a
this.b=b
this.$ti=c},
dm:function dm(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
t:function t(a,b,c){this.a=a
this.b=b
this.$ti=c},
cn:function cn(a,b,c){this.a=a
this.b=b
this.$ti=c},
dI:function dI(a,b,c){this.a=a
this.b=b
this.$ti=c},
c7:function c7(a,b,c){this.a=a
this.b=b
this.$ti=c},
dc:function dc(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
j6:function j6(a,b,c){this.a=a
this.b=b
this.$ti=c},
dG:function dG(a,b,c){this.a=a
this.b=b
this.$ti=c},
db:function db(a){this.$ti=a},
aB:function aB(){},
ci:function ci(a,b){this.a=a
this.$ti=b},
e9:function e9(){},
oS(){throw A.c(A.cT("Cannot modify unmodifiable Map"))},
oT(){throw A.c(A.cT("Cannot modify constant Set"))},
oa(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
tu(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.aU.b(a)},
r(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.b2(a)
return s},
dx(a){var s,r=$.mH
if(r==null)r=$.mH=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
bk(a,b){var s,r,q,p,o,n=null,m=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(m==null)return n
if(3>=m.length)return A.a(m,3)
s=m[3]
if(b==null){if(s!=null)return parseInt(a,10)
if(m[2]!=null)return parseInt(a,16)
return n}if(b<2||b>36)throw A.c(A.aw(b,2,36,"radix",n))
if(b===10&&s!=null)return parseInt(a,10)
if(b<10||s==null){r=b<=10?47+b:86+b
q=m[1]
for(p=q.length,o=0;o<p;++o)if((q.charCodeAt(o)|32)>r)return n}return parseInt(a,b)},
am(a){var s,r
if(!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(a))return null
s=parseFloat(a)
if(isNaN(s)){r=B.a.p(a)
if(r==="NaN"||r==="+NaN"||r==="-NaN")return s
return null}return s},
dy(a){var s,r,q,p
if(a instanceof A.z)return A.aS(A.bt(a),null)
s=J.cz(a)
if(s===B.hz||s===B.hB||t.ak.b(a)){r=B.J(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.aS(A.bt(a),null)},
mI(a){var s,r,q
if(a==null||typeof a=="number"||A.kv(a))return J.b2(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.bP)return a.k(0)
if(a instanceof A.ah)return a.cq(!0)
s=$.ox()
for(r=0;r<1;++r){q=s[r].ep(a)
if(q!=null)return q}return"Instance of '"+A.dy(a)+"'"},
av(a){var s
if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.c.aI(s,10)|55296)>>>0,s&1023|56320)}throw A.c(A.aw(a,0,1114111,null,null))},
cN(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
pQ(a){var s=A.cN(a).getUTCFullYear()+0
return s},
pO(a){var s=A.cN(a).getUTCMonth()+1
return s},
pK(a){var s=A.cN(a).getUTCDate()+0
return s},
pL(a){var s=A.cN(a).getUTCHours()+0
return s},
pN(a){var s=A.cN(a).getUTCMinutes()+0
return s},
pP(a){var s=A.cN(a).getUTCSeconds()+0
return s},
pM(a){var s=A.cN(a).getUTCMilliseconds()+0
return s},
pJ(a){var s=a.$thrownJsError
if(s==null)return null
return A.eg(s)},
pR(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.al(a,s)
a.$thrownJsError=s
s.stack=""}},
aU(a){throw A.c(A.fl(a))},
a(a,b){if(a==null)J.S(a)
throw A.c(A.kA(a,b))},
kA(a,b){var s,r="index"
if(!A.nJ(b))return new A.b3(!0,b,r,null)
s=J.S(a)
if(b<0||b>=s)return A.h9(b,s,a,r)
return A.lm(b,r)},
fl(a){return new A.b3(!0,a,null,null)},
c(a){return A.al(a,new Error())},
al(a,b){var s
if(a==null)a=new A.bF()
b.dartException=a
s=A.u_
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
u_(){return J.b2(this.dartException)},
x(a,b){throw A.al(a,b==null?new Error():b)},
a8(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.x(A.rh(a,b,c),s)},
rh(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t._.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.dH("'"+s+"': Cannot "+o+" "+l+k+n)},
M(a){throw A.c(A.ag(a))},
bG(a){var s,r,q,p,o,n
a=A.a2(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.d([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.j7(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
j8(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
n1(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
l8(a,b){var s=b==null,r=s?null:b.method
return new A.eD(a,r,s?null:b.receiver)},
ac(a){if(a==null)return new A.hX(a)
if(typeof a!=="object")return a
if("dartException" in a)return A.cB(a,a.dartException)
return A.t3(a)},
cB(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
t3(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.c.aI(r,16)&8191)===10)switch(q){case 438:return A.cB(a,A.l8(A.r(s)+" (Error "+q+")",null))
case 445:case 5007:A.r(s)
return A.cB(a,new A.du())}}if(a instanceof TypeError){p=$.oh()
o=$.oi()
n=$.oj()
m=$.ok()
l=$.on()
k=$.oo()
j=$.om()
$.ol()
i=$.oq()
h=$.op()
g=p.ar(s)
if(g!=null)return A.cB(a,A.l8(A.I(s),g))
else{g=o.ar(s)
if(g!=null){g.method="call"
return A.cB(a,A.l8(A.I(s),g))}else if(n.ar(s)!=null||m.ar(s)!=null||l.ar(s)!=null||k.ar(s)!=null||j.ar(s)!=null||m.ar(s)!=null||i.ar(s)!=null||h.ar(s)!=null){A.I(s)
return A.cB(a,new A.du())}}return A.cB(a,new A.f0(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.dC()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.cB(a,new A.b3(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.dC()
return a},
eg(a){var s
if(a==null)return new A.e2(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.e2(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
ei(a){if(a==null)return J.aM(a)
if(typeof a=="object")return A.dx(a)
return J.aM(a)},
tb(a){if(typeof a=="number")return B.f.gU(a)
if(a instanceof A.fh)return A.dx(a)
if(a instanceof A.ah)return a.gU(a)
return A.ei(a)},
tk(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.u(0,a[s],a[r])}return b},
tl(a,b){var s,r=a.length
for(s=0;s<r;++s)b.l(0,a[s])
return b},
rz(a,b,c,d,e,f){t.e.a(a)
switch(A.K(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.c(A.p_("Unsupported number of arguments for wrapped closure"))},
d2(a,b){var s=a.$identity
if(!!s)return s
s=A.tc(a,b)
a.$identity=s
return s},
tc(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.rz)},
oQ(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.eS().constructor.prototype):Object.create(new A.cC(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.mi(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.oM(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.mi(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
oM(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.c("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.oJ)}throw A.c("Error in functionType of tearoff")},
oN(a,b,c,d){var s=A.mh
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
mi(a,b,c,d){if(c)return A.oP(a,b,d)
return A.oN(b.length,d,a,b)},
oO(a,b,c,d){var s=A.mh,r=A.oK
switch(b?-1:a){case 0:throw A.c(new A.eR("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
oP(a,b,c){var s,r
if($.mf==null)$.mf=A.me("interceptor")
if($.mg==null)$.mg=A.me("receiver")
s=b.length
r=A.oO(s,c,a,b)
return r},
lT(a){return A.oQ(a)},
oJ(a,b){return A.e7(v.typeUniverse,A.bt(a.a),b)},
mh(a){return a.a},
oK(a){return a.b},
me(a){var s,r,q,p=new A.cC("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.c(A.aG("Field name "+a+" not found.",null))},
o0(a){return v.getIsolateTag(a)},
uE(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
tx(a){var s,r,q,p,o,n=A.I($.o1.$1(a)),m=$.kB[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.kG[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.fj($.nX.$2(a,n))
if(q!=null){m=$.kB[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.kG[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.kL(s)
$.kB[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.kG[n]=s
return s}if(p==="-"){o=A.kL(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.o7(a,s)
if(p==="*")throw A.c(A.n2(n))
if(v.leafTags[n]===true){o=A.kL(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.o7(a,s)},
o7(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.m_(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
kL(a){return J.m_(a,!1,null,!!a.$iaO)},
tz(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.kL(s)
else return J.m_(s,c,null,null)},
tr(){if(!0===$.lX)return
$.lX=!0
A.ts()},
ts(){var s,r,q,p,o,n,m,l
$.kB=Object.create(null)
$.kG=Object.create(null)
A.tq()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.o8.$1(o)
if(n!=null){m=A.tz(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
tq(){var s,r,q,p,o,n,m=B.dN()
m=A.d1(B.dO,A.d1(B.dP,A.d1(B.K,A.d1(B.K,A.d1(B.dQ,A.d1(B.dR,A.d1(B.dS(B.J),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.o1=new A.kD(p)
$.nX=new A.kE(o)
$.o8=new A.kF(n)},
d1(a,b){return a(b)||b},
qZ(a,b){var s,r
for(s=0;s<a.length;++s){r=a[s]
if(!(s<b.length))return A.a(b,s)
if(!J.N(r,b[s]))return!1}return!0},
tf(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
l6(a,b,c,d,e,f){var s=b?"m":"",r=c?"":"i",q=d?"u":"",p=e?"s":"",o=function(g,h){try{return new RegExp(g,h)}catch(n){return n}}(a,s+r+q+p+f)
if(o instanceof RegExp)return o
throw A.c(A.dd("Illegal RegExp pattern ("+String(o)+")",a))},
tR(a,b,c){var s=a.indexOf(b,c)
return s>=0},
lU(a){if(a.indexOf("$",0)>=0)return a.replace(/\$/g,"$$$$")
return a},
tU(a,b,c,d){var s=b.bx(a,d)
if(s==null)return a
return A.tV(a,s.b.index,s.gaK(),c)},
a2(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
A(a,b,c){var s
if(typeof b=="string")return A.tT(a,b,c)
if(b instanceof A.ca){s=b.gcf()
s.lastIndex=0
return a.replace(s,A.lU(c))}return A.tS(a,b,c)},
tS(a,b,c){var s,r,q,p
for(s=J.m8(b,a),s=s.gC(s),r=0,q="";s.q();){p=s.gD()
q=q+a.substring(r,p.gbp())+c
r=p.gaK()}s=q+a.substring(r)
return s.charCodeAt(0)==0?s:s},
tT(a,b,c){var s,r,q
if(b===""){if(a==="")return c
s=a.length
for(r=c,q=0;q<s;++q)r=r+a[q]+c
return r.charCodeAt(0)==0?r:r}if(a.indexOf(b,0)<0)return a
if(a.length<500||c.indexOf("$",0)>=0)return a.split(b).join(c)
return a.replace(new RegExp(A.a2(b),"g"),A.lU(c))},
nW(a){return a},
kU(a,b,c,d){var s,r,q,p,o,n,m
for(s=b.am(0,a),s=new A.co(s.a,s.b,s.c),r=t.F,q=0,p="";s.q();){o=s.d
if(o==null)o=r.a(o)
n=o.b
m=n.index
p=p+A.r(A.nW(B.a.F(a,q,m)))+A.r(c.$1(o))
q=m+n[0].length}s=p+A.r(A.nW(B.a.M(a,q)))
return s.charCodeAt(0)==0?s:s},
m0(a,b,c,d){return d===0?a.replace(b.b,A.lU(c)):A.tU(a,b,c,d)},
tV(a,b,c,d){return a.substring(0,b)+d+a.substring(c)},
R:function R(a,b){this.a=a
this.b=b},
dX:function dX(a,b){this.a=a
this.b=b},
bp:function bp(a,b){this.a=a
this.b=b},
dY:function dY(a,b){this.a=a
this.b=b},
dZ:function dZ(a,b){this.a=a
this.b=b},
cY:function cY(a,b){this.a=a
this.b=b},
e_:function e_(a,b,c){this.a=a
this.b=b
this.c=c},
cu:function cu(a,b,c){this.a=a
this.b=b
this.c=c},
aR:function aR(a,b,c){this.a=a
this.b=b
this.c=c},
c0:function c0(a){this.a=a},
e0:function e0(a){this.a=a},
da:function da(){},
bQ:function bQ(a,b,c){this.a=a
this.b=b
this.$ti=c},
cr:function cr(a,b){this.a=a
this.$ti=b},
bI:function bI(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
cD:function cD(){},
bR:function bR(a,b,c){this.a=a
this.b=b
this.$ti=c},
bS:function bS(a,b){this.a=a
this.$ti=b},
dB:function dB(){},
j7:function j7(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
du:function du(){},
eD:function eD(a,b,c){this.a=a
this.b=b
this.c=c},
f0:function f0(a){this.a=a},
hX:function hX(a){this.a=a},
e2:function e2(a){this.a=a
this.b=null},
bP:function bP(){},
ep:function ep(){},
eq:function eq(){},
eZ:function eZ(){},
eS:function eS(){},
cC:function cC(a,b){this.a=a
this.b=b},
eR:function eR(a){this.a=a},
b4:function b4(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
hl:function hl(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
at:function at(a,b){this.a=a
this.$ti=b},
aP:function aP(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
dk:function dk(a,b){this.a=a
this.$ti=b},
dj:function dj(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
O:function O(a,b){this.a=a
this.$ti=b},
b5:function b5(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
dg:function dg(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
kD:function kD(a){this.a=a},
kE:function kE(a){this.a=a},
kF:function kF(a){this.a=a},
ah:function ah(){},
bb:function bb(){},
c_:function c_(){},
ct:function ct(){},
ca:function ca(a,b){var _=this
_.a=a
_.b=b
_.e=_.d=_.c=null},
cX:function cX(a){this.b=a},
f2:function f2(a,b,c){this.a=a
this.b=b
this.c=c},
co:function co(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
dE:function dE(a,b){this.a=a
this.c=b},
fd:function fd(a,b,c){this.a=a
this.b=b
this.c=c},
fe:function fe(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
tZ(a){throw A.al(new A.di("Field '"+a+"' has been assigned during initialization."),new Error())},
jo(a){var s=new A.jn(a)
return s.b=s},
jn:function jn(a){this.a=a
this.b=null},
pw(a,b,c){var s=new DataView(a,b)
return s},
px(a){return new Uint16Array(a)},
py(a){return new Uint8Array(a)},
c2(a,b,c){if(a>>>0!==a||a>=c)throw A.c(A.kA(b,a))},
cd:function cd(){},
dr:function dr(){},
fi:function fi(a){this.a=a},
eG:function eG(){},
cL:function cL(){},
dp:function dp(){},
dq:function dq(){},
eH:function eH(){},
eI:function eI(){},
eJ:function eJ(){},
eK:function eK(){},
eL:function eL(){},
eM:function eM(){},
eN:function eN(){},
ds:function ds(){},
dt:function dt(){},
dT:function dT(){},
dU:function dU(){},
dV:function dV(){},
dW:function dW(){},
lo(a,b){var s=b.c
return s==null?b.c=A.e5(a,"cG",[b.x]):s},
mS(a){var s=a.w
if(s===6||s===7)return A.mS(a.x)
return s===11||s===12},
qg(a){return a.as},
o6(a,b){var s,r=b.length
for(s=0;s<r;++s)if(!a[s].b(b[s]))return!1
return!0},
bM(a){return A.k5(v.typeUniverse,a,!1)},
cw(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.cw(a1,s,a3,a4)
if(r===s)return a2
return A.nr(a1,r,!0)
case 7:s=a2.x
r=A.cw(a1,s,a3,a4)
if(r===s)return a2
return A.nq(a1,r,!0)
case 8:q=a2.y
p=A.d0(a1,q,a3,a4)
if(p===q)return a2
return A.e5(a1,a2.x,p)
case 9:o=a2.x
n=A.cw(a1,o,a3,a4)
m=a2.y
l=A.d0(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.lN(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.d0(a1,j,a3,a4)
if(i===j)return a2
return A.ns(a1,k,i)
case 11:h=a2.x
g=A.cw(a1,h,a3,a4)
f=a2.y
e=A.t0(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.np(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.d0(a1,d,a3,a4)
o=a2.x
n=A.cw(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.lO(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.c(A.em("Attempted to substitute unexpected RTI kind "+a0))}},
d0(a,b,c,d){var s,r,q,p,o=b.length,n=A.k6(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.cw(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
t1(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.k6(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.cw(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
t0(a,b,c,d){var s,r=b.a,q=A.d0(a,r,c,d),p=b.b,o=A.d0(a,p,c,d),n=b.c,m=A.t1(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.f7()
s.a=q
s.b=o
s.c=m
return s},
d(a,b){a[v.arrayRti]=b
return a},
nZ(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.tp(s)
return a.$S()}return null},
tt(a,b){var s
if(A.mS(b))if(a instanceof A.bP){s=A.nZ(a)
if(s!=null)return s}return A.bt(a)},
bt(a){if(a instanceof A.z)return A.q(a)
if(Array.isArray(a))return A.H(a)
return A.lP(J.cz(a))},
H(a){var s=a[v.arrayRti],r=t.gn
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
q(a){var s=a.$ti
return s!=null?s:A.lP(a)},
lP(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.rv(a,s)},
rv(a,b){var s=a instanceof A.bP?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.r8(v.typeUniverse,s.name)
b.$ccache=r
return r},
tp(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.k5(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
to(a){return A.cy(A.q(a))},
lS(a){var s
if(a instanceof A.ah)return A.ti(a.$r,a.bc())
s=a instanceof A.bP?A.nZ(a):null
if(s!=null)return s
if(t.dm.b(a))return J.oF(a).a
if(Array.isArray(a))return A.H(a)
return A.bt(a)},
cy(a){var s=a.r
return s==null?a.r=new A.fh(a):s},
ti(a,b){var s,r,q=b,p=q.length
if(p===0)return t.bQ
if(0>=p)return A.a(q,0)
s=A.e7(v.typeUniverse,A.lS(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.a(q,r)
s=A.nt(v.typeUniverse,s,A.lS(q[r]))}return A.e7(v.typeUniverse,s,a)},
bc(a){return A.cy(A.k5(v.typeUniverse,a,!1))},
ru(a){var s=this
s.b=A.rY(s)
return s.b(a)},
rY(a){var s,r,q,p,o
if(a===t.K)return A.rF
if(A.cA(a))return A.rJ
s=a.w
if(s===6)return A.rq
if(s===1)return A.nL
if(s===7)return A.rA
r=A.rX(a)
if(r!=null)return r
if(s===8){q=a.x
if(a.y.every(A.cA)){a.f="$i"+q
if(q==="n")return A.rD
if(a===t.m)return A.rC
return A.rI}}else if(s===10){p=A.tf(a.x,a.y)
o=p==null?A.nL:p
return o==null?A.cv(o):o}return A.ro},
rX(a){if(a.w===8){if(a===t.p)return A.nJ
if(a===t.V||a===t.o)return A.rE
if(a===t.N)return A.rH
if(a===t.y)return A.kv}return null},
rt(a){var s=this,r=A.rn
if(A.cA(s))r=A.rd
else if(s===t.K)r=A.cv
else if(A.d3(s)){r=A.rp
if(s===t.h6)r=A.nw
else if(s===t.dk)r=A.fj
else if(s===t.fQ)r=A.ra
else if(s===t.cg)r=A.ny
else if(s===t.cD)r=A.rb
else if(s===t.bX)r=A.nx}else if(s===t.p)r=A.K
else if(s===t.N)r=A.I
else if(s===t.y)r=A.cZ
else if(s===t.o)r=A.aK
else if(s===t.V)r=A.bs
else if(s===t.m)r=A.rc
s.a=r
return s.a(a)},
ro(a){var s=this
if(a==null)return A.d3(s)
return A.tv(v.typeUniverse,A.tt(a,s),s)},
rq(a){if(a==null)return!0
return this.x.b(a)},
rI(a){var s,r=this
if(a==null)return A.d3(r)
s=r.f
if(a instanceof A.z)return!!a[s]
return!!J.cz(a)[s]},
rD(a){var s,r=this
if(a==null)return A.d3(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.z)return!!a[s]
return!!J.cz(a)[s]},
rC(a){var s=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.z)return!!a[s.f]
return!0}if(typeof a=="function")return!0
return!1},
nK(a){if(typeof a=="object"){if(a instanceof A.z)return t.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
rn(a){var s=this
if(a==null){if(A.d3(s))return a}else if(s.b(a))return a
throw A.al(A.nC(a,s),new Error())},
rp(a){var s=this
if(a==null||s.b(a))return a
throw A.al(A.nC(a,s),new Error())},
nC(a,b){return new A.e3("TypeError: "+A.nb(a,A.aS(b,null)))},
nb(a,b){return A.ex(a)+": type '"+A.aS(A.lS(a),null)+"' is not a subtype of type '"+b+"'"},
b0(a,b){return new A.e3("TypeError: "+A.nb(a,b))},
rA(a){var s=this
return s.x.b(a)||A.lo(v.typeUniverse,s).b(a)},
rF(a){return a!=null},
cv(a){if(a!=null)return a
throw A.al(A.b0(a,"Object"),new Error())},
rJ(a){return!0},
rd(a){return a},
nL(a){return!1},
kv(a){return!0===a||!1===a},
cZ(a){if(!0===a)return!0
if(!1===a)return!1
throw A.al(A.b0(a,"bool"),new Error())},
ra(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.al(A.b0(a,"bool?"),new Error())},
bs(a){if(typeof a=="number")return a
throw A.al(A.b0(a,"double"),new Error())},
rb(a){if(typeof a=="number")return a
if(a==null)return a
throw A.al(A.b0(a,"double?"),new Error())},
nJ(a){return typeof a=="number"&&Math.floor(a)===a},
K(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.al(A.b0(a,"int"),new Error())},
nw(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.al(A.b0(a,"int?"),new Error())},
rE(a){return typeof a=="number"},
aK(a){if(typeof a=="number")return a
throw A.al(A.b0(a,"num"),new Error())},
ny(a){if(typeof a=="number")return a
if(a==null)return a
throw A.al(A.b0(a,"num?"),new Error())},
rH(a){return typeof a=="string"},
I(a){if(typeof a=="string")return a
throw A.al(A.b0(a,"String"),new Error())},
fj(a){if(typeof a=="string")return a
if(a==null)return a
throw A.al(A.b0(a,"String?"),new Error())},
rc(a){if(A.nK(a))return a
throw A.al(A.b0(a,"JSObject"),new Error())},
nx(a){if(a==null)return a
if(A.nK(a))return a
throw A.al(A.b0(a,"JSObject?"),new Error())},
nT(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.aS(a[q],b)
return s},
rP(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.nT(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.aS(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
nF(a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", ",a2=null
if(a5!=null){s=a5.length
if(a4==null)a4=A.d([],t.s)
else a2=a4.length
r=a4.length
for(q=s;q>0;--q)B.b.l(a4,"T"+(r+q))
for(p=t.O,o="<",n="",q=0;q<s;++q,n=a1){m=a4.length
l=m-1-q
if(!(l>=0))return A.a(a4,l)
o=o+n+a4[l]
k=a5[q]
j=k.w
if(!(j===2||j===3||j===4||j===5||k===p))o+=" extends "+A.aS(k,a4)}o+=">"}else o=""
p=a3.x
i=a3.y
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.aS(p,a4)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.aS(h[q],a4)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.aS(f[q],a4)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.aS(d[q+2],a4)+" "+d[q]}a+="}"}if(a2!=null){a4.toString
a4.length=a2}return o+"("+a+") => "+b},
aS(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6){s=a.x
r=A.aS(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(l===7)return"FutureOr<"+A.aS(a.x,b)+">"
if(l===8){p=A.t2(a.x)
o=a.y
return o.length>0?p+("<"+A.nT(o,b)+">"):p}if(l===10)return A.rP(a,b)
if(l===11)return A.nF(a,b,null)
if(l===12)return A.nF(a.x,b,a.y)
if(l===13){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.a(b,n)
return b[n]}return"?"},
t2(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
r9(a,b){var s=a.tR[b]
while(typeof s=="string")s=a.tR[s]
return s},
r8(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.k5(a,b,!1)
else if(typeof m=="number"){s=m
r=A.e6(a,5,"#")
q=A.k6(s)
for(p=0;p<s;++p)q[p]=r
o=A.e5(a,b,q)
n[b]=o
return o}else return m},
r7(a,b){return A.nu(a.tR,b)},
r6(a,b){return A.nu(a.eT,b)},
k5(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.nj(A.nh(a,null,b,!1))
r.set(b,s)
return s},
e7(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.nj(A.nh(a,b,c,!0))
q.set(c,r)
return r},
nt(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.lN(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
c1(a,b){b.a=A.rt
b.b=A.ru
return b},
e6(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.b7(null,null)
s.w=b
s.as=c
r=A.c1(a,s)
a.eC.set(c,r)
return r},
nr(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.r4(a,b,r,c)
a.eC.set(r,s)
return s},
r4(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.cA(b))if(!(b===t.b||b===t.T))if(s!==6)r=s===7&&A.d3(b.x)
if(r)return b
else if(s===1)return t.b}q=new A.b7(null,null)
q.w=6
q.x=b
q.as=c
return A.c1(a,q)},
nq(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.r2(a,b,r,c)
a.eC.set(r,s)
return s},
r2(a,b,c,d){var s,r
if(d){s=b.w
if(A.cA(b)||b===t.K)return b
else if(s===1)return A.e5(a,"cG",[b])
else if(b===t.b||b===t.T)return t.eH}r=new A.b7(null,null)
r.w=7
r.x=b
r.as=c
return A.c1(a,r)},
r5(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.b7(null,null)
s.w=13
s.x=b
s.as=q
r=A.c1(a,s)
a.eC.set(q,r)
return r},
e4(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
r1(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
e5(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.e4(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.b7(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.c1(a,r)
a.eC.set(p,q)
return q},
lN(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.e4(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.b7(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.c1(a,o)
a.eC.set(q,n)
return n},
ns(a,b,c){var s,r,q="+"+(b+"("+A.e4(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.b7(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.c1(a,s)
a.eC.set(q,r)
return r},
np(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.e4(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.e4(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.r1(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.b7(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.c1(a,p)
a.eC.set(r,o)
return o},
lO(a,b,c,d){var s,r=b.as+("<"+A.e4(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.r3(a,b,c,r,d)
a.eC.set(r,s)
return s},
r3(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.k6(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.cw(a,b,r,0)
m=A.d0(a,c,r,0)
return A.lO(a,n,m,c!==m)}}l=new A.b7(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.c1(a,l)},
nh(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
nj(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.qU(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.ni(a,r,l,k,!1)
else if(q===46)r=A.ni(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.cs(a.u,a.e,k.pop()))
break
case 94:k.push(A.r5(a.u,k.pop()))
break
case 35:k.push(A.e6(a.u,5,"#"))
break
case 64:k.push(A.e6(a.u,2,"@"))
break
case 126:k.push(A.e6(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.qW(a,k)
break
case 38:A.qV(a,k)
break
case 63:p=a.u
k.push(A.nr(p,A.cs(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.nq(p,A.cs(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.qT(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.nk(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.qY(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.cs(a.u,a.e,m)},
qU(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
ni(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.r9(s,o.x)[p]
if(n==null)A.x('No "'+p+'" in "'+A.qg(o)+'"')
d.push(A.e7(s,o,n))}else d.push(p)
return m},
qW(a,b){var s,r=a.u,q=A.ng(a,b),p=b.pop()
if(typeof p=="string")b.push(A.e5(r,p,q))
else{s=A.cs(r,a.e,p)
switch(s.w){case 11:b.push(A.lO(r,s,q,a.n))
break
default:b.push(A.lN(r,s,q))
break}}},
qT(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.ng(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.cs(p,a.e,o)
q=new A.f7()
q.a=s
q.b=n
q.c=m
b.push(A.np(p,r,q))
return
case-4:b.push(A.ns(p,b.pop(),s))
return
default:throw A.c(A.em("Unexpected state under `()`: "+A.r(o)))}},
qV(a,b){var s=b.pop()
if(0===s){b.push(A.e6(a.u,1,"0&"))
return}if(1===s){b.push(A.e6(a.u,4,"1&"))
return}throw A.c(A.em("Unexpected extended operation "+A.r(s)))},
ng(a,b){var s=b.splice(a.p)
A.nk(a.u,a.e,s)
a.p=b.pop()
return s},
cs(a,b,c){if(typeof c=="string")return A.e5(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.qX(a,b,c)}else return c},
nk(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.cs(a,b,c[s])},
qY(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.cs(a,b,c[s])},
qX(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.c(A.em("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.c(A.em("Bad index "+c+" for "+b.k(0)))},
tv(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.ai(a,b,null,c,null)
r.set(c,s)}return s},
ai(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.cA(d))return!0
s=b.w
if(s===4)return!0
if(A.cA(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.ai(a,c[b.x],c,d,e))return!0
q=d.w
p=t.b
if(b===p||b===t.T){if(q===7)return A.ai(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.ai(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.ai(a,b.x,c,d,e))return!1
return A.ai(a,A.lo(a,b),c,d,e)}if(s===6)return A.ai(a,p,c,d,e)&&A.ai(a,b.x,c,d,e)
if(q===7){if(A.ai(a,b,c,d.x,e))return!0
return A.ai(a,b,c,A.lo(a,d),e)}if(q===6)return A.ai(a,b,c,p,e)||A.ai(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.e)return!0
o=s===10
if(o&&d===t.gT)return!0
if(q===12){if(b===t.cj)return!0
if(s!==12)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.ai(a,j,c,i,e)||!A.ai(a,i,e,j,c))return!1}return A.nI(a,b.x,c,d.x,e)}if(q===11){if(b===t.cj)return!0
if(p)return!1
return A.nI(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.rB(a,b,c,d,e)}if(o&&q===10)return A.rG(a,b,c,d,e)
return!1},
nI(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.ai(a3,a4.x,a5,a6.x,a7))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.ai(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.ai(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.ai(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.ai(a3,e[a+2],a7,g,a5))return!1
break}}while(b<d){if(f[b+1])return!1
b+=3}return!0},
rB(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
while(n!==m){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.e7(a,b,r[o])
return A.nv(a,p,null,c,d.y,e)}return A.nv(a,b.y,null,c,d.y,e)},
nv(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.ai(a,b[s],d,e[s],f))return!1
return!0},
rG(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.ai(a,r[s],c,q[s],e))return!1
return!0},
d3(a){var s=a.w,r=!0
if(!(a===t.b||a===t.T))if(!A.cA(a))if(s!==6)r=s===7&&A.d3(a.x)
return r},
cA(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.O},
nu(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
k6(a){return a>0?new Array(a):v.typeUniverse.sEA},
b7:function b7(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
f7:function f7(){this.c=this.b=this.a=null},
fh:function fh(a){this.a=a},
f6:function f6(){},
e3:function e3(a){this.a=a},
qG(){var s,r,q
if(self.scheduleImmediate!=null)return A.t6()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.d2(new A.je(s),1)).observe(r,{childList:true})
return new A.jd(s,r,q)}else if(self.setImmediate!=null)return A.t7()
return A.t8()},
qH(a){self.scheduleImmediate(A.d2(new A.jf(t.M.a(a)),0))},
qI(a){self.setImmediate(A.d2(new A.jg(t.M.a(a)),0))},
qJ(a){t.M.a(a)
A.r0(0,a)},
r0(a,b){var s=new A.k3()
s.cU(a,b)
return s},
no(a,b,c){return 0},
l1(a){var s
if(t.C.b(a)){s=a.gb1()
if(s!=null)return s}return B.x},
rw(a,b){if($.ak===B.k)return null
return null},
rx(a,b){if($.ak!==B.k)A.rw(a,b)
if(t.C.b(a)){b=a.gb1()
if(b==null){A.pR(a,B.x)
b=B.x}}else b=B.x
return new A.bd(a,b)},
lD(a,b,c){var s,r,q,p,o={},n=o.a=a
for(s=t.D;r=n.a,(r&4)!==0;n=a){a=s.a(n.c)
o.a=a}if(n===b){s=A.qh()
b.c2(new A.bd(new A.b3(!0,n,null,"Cannot complete a future with itself"),s))
return}q=b.a&1
s=n.a=r|q
if((s&24)===0){p=t.d.a(b.c)
b.a=b.a&1|4
b.c=n
n.cm(p)
return}if(!c)if(b.c==null)n=(s&16)===0||q!==0
else n=!1
else n=!0
if(n){p=b.bg()
b.bb(o.a)
A.cV(b,p)
return}b.a^=2
A.fk(null,null,b.b,t.M.a(new A.jx(o,b)))},
cV(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d={},c=d.a=a
for(s=t.u,r=t.d;;){q={}
p=c.a
o=(p&16)===0
n=!o
if(b==null){if(n&&(p&1)===0){m=s.a(c.c)
A.lR(m.a,m.b)}return}q.a=b
l=b.a
for(c=b;l!=null;c=l,l=k){c.a=null
A.cV(d.a,c)
q.a=l
k=l.a}p=d.a
j=p.c
q.b=n
q.c=j
if(o){i=c.c
i=(i&1)!==0||(i&15)===8}else i=!0
if(i){h=c.b.b
if(n){p=p.b===h
p=!(p||p)}else p=!1
if(p){s.a(j)
A.lR(j.a,j.b)
return}g=$.ak
if(g!==h)$.ak=h
else g=null
c=c.c
if((c&15)===8)new A.jB(q,d,n).$0()
else if(o){if((c&1)!==0)new A.jA(q,j).$0()}else if((c&2)!==0)new A.jz(d,q).$0()
if(g!=null)$.ak=g
c=q.c
if(c instanceof A.b_){p=q.a.$ti
p=p.h("cG<2>").b(c)||!p.y[1].b(c)}else p=!1
if(p){f=q.a.b
if((c.a&24)!==0){e=r.a(f.c)
f.c=null
b=f.bh(e)
f.a=c.a&30|f.a&1
f.c=c.c
d.a=c
continue}else A.lD(c,f,!0)
return}}f=q.a.b
e=r.a(f.c)
f.c=null
b=f.bh(e)
c=q.b
p=q.c
if(!c){f.$ti.c.a(p)
f.a=8
f.c=p}else{s.a(p)
f.a=f.a&1|16
f.c=p}d.a=f
c=f}},
rQ(a,b){var s=t.ag
if(s.b(a))return s.a(a)
s=t.E
if(s.b(a))return s.a(a)
throw A.c(A.fp(a,"onError",u.c))},
rM(){var s,r
for(s=$.d_;s!=null;s=$.d_){$.ec=null
r=s.b
$.d_=r
if(r==null)$.eb=null
s.a.$0()}},
t_(){$.lQ=!0
try{A.rM()}finally{$.ec=null
$.lQ=!1
if($.d_!=null)$.m3().$1(A.nY())}},
nU(a){var s=new A.f3(a),r=$.eb
if(r==null){$.d_=$.eb=s
if(!$.lQ)$.m3().$1(A.nY())}else $.eb=r.b=s},
rW(a){var s,r,q,p=$.d_
if(p==null){A.nU(a)
$.ec=$.eb
return}s=new A.f3(a)
r=$.ec
if(r==null){s.b=p
$.d_=$.ec=s}else{q=r.b
s.b=q
$.ec=r.b=s
if(q==null)$.eb=s}},
lR(a,b){A.rW(new A.kx(a,b))},
nS(a,b,c,d,e){var s,r=$.ak
if(r===c)return d.$0()
$.ak=c
s=r
try{r=d.$0()
return r}finally{$.ak=s}},
rV(a,b,c,d,e,f,g){var s,r=$.ak
if(r===c)return d.$1(e)
$.ak=c
s=r
try{r=d.$1(e)
return r}finally{$.ak=s}},
rU(a,b,c,d,e,f,g,h,i){var s,r=$.ak
if(r===c)return d.$2(e,f)
$.ak=c
s=r
try{r=d.$2(e,f)
return r}finally{$.ak=s}},
fk(a,b,c,d){t.M.a(d)
if(B.k!==c){d=c.dU(d)
d=d}A.nU(d)},
je:function je(a){this.a=a},
jd:function jd(a,b,c){this.a=a
this.b=b
this.c=c},
jf:function jf(a){this.a=a},
jg:function jg(a){this.a=a},
k3:function k3(){},
k4:function k4(a,b){this.a=a
this.b=b},
af:function af(a,b){var _=this
_.a=a
_.e=_.d=_.c=_.b=null
_.$ti=b},
br:function br(a,b){this.a=a
this.$ti=b},
bd:function bd(a,b){this.a=a
this.b=b},
f5:function f5(){},
dJ:function dJ(a,b){this.a=a
this.$ti=b},
dO:function dO(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
b_:function b_(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
ju:function ju(a,b){this.a=a
this.b=b},
jy:function jy(a,b){this.a=a
this.b=b},
jx:function jx(a,b){this.a=a
this.b=b},
jw:function jw(a,b){this.a=a
this.b=b},
jv:function jv(a,b){this.a=a
this.b=b},
jB:function jB(a,b,c){this.a=a
this.b=b
this.c=c},
jC:function jC(a,b){this.a=a
this.b=b},
jD:function jD(a){this.a=a},
jA:function jA(a,b){this.a=a
this.b=b},
jz:function jz(a,b){this.a=a
this.b=b},
f3:function f3(a){this.a=a
this.b=null},
e8:function e8(){},
fa:function fa(){},
k1:function k1(a,b){this.a=a
this.b=b},
kx:function kx(a,b){this.a=a
this.b=b},
lF(a,b){var s=a[b]
return s===a?null:s},
lH(a,b,c){if(c==null)a[b]=a
else a[b]=c},
lG(){var s=Object.create(null)
A.lH(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
p5(a,b){return new A.b4(a.h("@<0>").L(b).h("b4<1,2>"))},
B(a,b,c){return b.h("@<0>").L(c).h("l9<1,2>").a(A.tk(a,new A.b4(b.h("@<0>").L(c).h("b4<1,2>"))))},
X(a,b){return new A.b4(a.h("@<0>").L(b).h("b4<1,2>"))},
mr(a){return new A.bJ(a.h("bJ<0>"))},
cK(a){return new A.bJ(a.h("bJ<0>"))},
ms(a,b){return b.h("mq<0>").a(A.tl(a,new A.bJ(b.h("bJ<0>"))))},
lI(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
f9(a,b,c){var s=new A.ba(a,b,c.h("ba<0>"))
s.c=a.e
return s},
eF(a,b,c){var s=A.p5(b,c)
a.aL(0,new A.hm(s,b,c))
return s},
p6(a,b){var s,r,q=A.mr(b)
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.M)(a),++r)q.l(0,b.a(a[r]))
return q},
hn(a,b){var s=A.mr(b)
s.aJ(0,a)
return s},
lb(a){var s,r
if(A.lZ(a))return"{...}"
s=new A.bm("")
try{r={}
B.b.l($.aT,a)
s.a+="{"
r.a=!0
a.aL(0,new A.hp(r,s))
s.a+="}"}finally{if(0>=$.aT.length)return A.a($.aT,-1)
$.aT.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
dP:function dP(){},
jE:function jE(a){this.a=a},
cW:function cW(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
cq:function cq(a,b){this.a=a
this.$ti=b},
dQ:function dQ(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bJ:function bJ(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
f8:function f8(a){this.a=a
this.b=null},
ba:function ba(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
hm:function hm(a,b,c){this.a=a
this.b=b
this.c=c},
P:function P(){},
Q:function Q(){},
ho:function ho(a){this.a=a},
hp:function hp(a,b){this.a=a
this.b=b},
dR:function dR(a,b){this.a=a
this.$ti=b},
dS:function dS(a,b,c){var _=this
_.a=a
_.b=b
_.c=null
_.$ti=c},
bC:function bC(){},
e1:function e1(){},
mp(a,b,c){return new A.dh(a,b)},
rg(a){return a.b0()},
qQ(a,b){return new A.jG(a,[],A.td())},
qR(a,b,c){var s,r=new A.bm(""),q=A.qQ(r,b)
q.bo(a)
s=r.a
return s.charCodeAt(0)==0?s:s},
er:function er(){},
eu:function eu(){},
dh:function dh(a,b){this.a=a
this.b=b},
eE:function eE(a,b){this.a=a
this.b=b},
he:function he(){},
hf:function hf(a){this.b=a},
jH:function jH(){},
jI:function jI(a,b){this.a=a
this.b=b},
jG:function jG(a,b,c){this.c=a
this.a=b
this.b=c},
ae(a,b){var s=A.jh(a,b)
if(s==null)throw A.c(A.dd("Could not parse BigInt",a))
return s},
qN(a,b){var s,r,q=$.p(),p=a.length,o=4-p%4
if(o===4)o=0
for(s=0,r=0;r<p;++r){s=s*10+a.charCodeAt(r)-48;++o
if(o===4){q=q.i(0,$.m4()).A(0,A.dK(s))
s=0
o=0}}if(b)return q.n(0)
return q},
n4(a){if(48<=a&&a<=57)return a-48
return(a|32)-97+10},
qO(a,b,c){var s,r,q,p,o,n,m,l=a.length,k=l-b,j=B.f.cv(k/4),i=new Uint16Array(j),h=j-1,g=k-h*4
for(s=b,r=0,q=0;q<g;++q,s=p){p=s+1
if(!(s<l))return A.a(a,s)
o=A.n4(a.charCodeAt(s))
if(o>=16)return null
r=r*16+o}n=h-1
if(!(h>=0&&h<j))return A.a(i,h)
i[h]=r
for(;s<l;n=m){for(r=0,q=0;q<4;++q,s=p){p=s+1
if(!(s>=0&&s<l))return A.a(a,s)
o=A.n4(a.charCodeAt(s))
if(o>=16)return null
r=r*16+o}m=n-1
if(!(n>=0&&n<j))return A.a(i,n)
i[n]=r}if(j===1){if(0>=j)return A.a(i,0)
l=i[0]===0}else l=!1
if(l)return $.p()
l=A.aF(j,i)
return new A.ab(l===0?!1:c,i,l)},
jh(a,b){var s,r,q,p,o,n
if(a==="")return null
s=$.os().a3(a)
if(s==null)return null
r=s.b
q=r.length
if(1>=q)return A.a(r,1)
p=r[1]==="-"
if(4>=q)return A.a(r,4)
o=r[4]
n=r[3]
if(5>=q)return A.a(r,5)
if(o!=null)return A.qN(o,p)
if(n!=null)return A.qO(n,2,p)
return null},
aF(a,b){var s,r=b.length
for(;;){if(a>0){s=a-1
if(!(s<r))return A.a(b,s)
s=b[s]===0}else s=!1
if(!s)break;--a}return a},
cU(a,b,c,d){var s,r,q,p=new Uint16Array(d),o=c-b
for(s=a.length,r=0;r<o;++r){q=b+r
if(!(q>=0&&q<s))return A.a(a,q)
q=a[q]
if(!(r<d))return A.a(p,r)
p[r]=q}return p},
C(a){var s
if(a===0)return $.p()
if(a===1)return $.o()
if(a===2)return $.bO()
if(Math.abs(a)<4294967296)return A.dK(B.c.ai(a))
s=A.qK(a)
return s},
dK(a){var s,r,q,p,o=a<0
if(o){if(a===-9223372036854776e3){s=new Uint16Array(4)
s[3]=32768
r=A.aF(4,s)
return new A.ab(r!==0,s,r)}a=-a}if(a<65536){s=new Uint16Array(1)
s[0]=a
r=A.aF(1,s)
return new A.ab(r===0?!1:o,s,r)}if(a<=4294967295){s=new Uint16Array(2)
s[0]=a&65535
s[1]=B.c.aI(a,16)
r=A.aF(2,s)
return new A.ab(r===0?!1:o,s,r)}r=B.c.S(B.c.gt(a)-1,16)+1
s=new Uint16Array(r)
for(q=0;a!==0;q=p){p=q+1
if(!(q<r))return A.a(s,q)
s[q]=a&65535
a=B.c.S(a,65536)}r=A.aF(r,s)
return new A.ab(r===0?!1:o,s,r)},
qK(a){var s,r,q,p,o,n,m,l
if(isNaN(a)||a==1/0||a==-1/0)throw A.c(A.aG("Value must be finite: "+a,null))
s=a<0
if(s)a=-a
a=Math.floor(a)
if(a===0)return $.p()
r=$.or()
for(q=r.$flags|0,p=0;p<8;++p){q&2&&A.a8(r)
if(!(p<8))return A.a(r,p)
r[p]=0}q=J.m9(B.E.gcu(r))
q.$flags&2&&A.a8(q,13)
q.setFloat64(0,a,!0)
o=(r[7]<<4>>>0)+(r[6]>>>4)-1075
n=new Uint16Array(4)
n[0]=(r[1]<<8>>>0)+r[0]
n[1]=(r[3]<<8>>>0)+r[2]
n[2]=(r[5]<<8>>>0)+r[4]
n[3]=r[6]&15|16
m=new A.ab(!1,n,4)
if(o<0)l=m.ak(0,-o)
else l=o>0?m.aj(0,o):m
if(s)return l.n(0)
return l},
lB(a,b,c,d){var s,r,q,p,o
if(b===0)return 0
if(c===0&&d===a)return b
for(s=b-1,r=a.length,q=d.$flags|0;s>=0;--s){p=s+c
if(!(s<r))return A.a(a,s)
o=a[s]
q&2&&A.a8(d)
if(!(p>=0&&p<d.length))return A.a(d,p)
d[p]=o}for(s=c-1;s>=0;--s){q&2&&A.a8(d)
if(!(s<d.length))return A.a(d,s)
d[s]=0}return b+c},
n9(a,b,c,d){var s,r,q,p,o,n,m,l=B.c.S(c,16),k=B.c.W(c,16),j=16-k,i=B.c.aj(1,j)-1
for(s=b-1,r=a.length,q=d.$flags|0,p=0;s>=0;--s){if(!(s<r))return A.a(a,s)
o=a[s]
n=s+l+1
m=B.c.bG(o,j)
q&2&&A.a8(d)
if(!(n>=0&&n<d.length))return A.a(d,n)
d[n]=(m|p)>>>0
p=B.c.aj(o&i,k)}q&2&&A.a8(d)
if(!(l>=0&&l<d.length))return A.a(d,l)
d[l]=p},
lC(a,b,c,d){var s,r,q,p=B.c.S(c,16)
if(B.c.W(c,16)===0)return A.lB(a,b,p,d)
s=b+p+1
A.n9(a,b,c,d)
for(r=d.$flags|0,q=p;--q,q>=0;){r&2&&A.a8(d)
if(!(q<d.length))return A.a(d,q)
d[q]=0}r=s-1
if(!(r>=0&&r<d.length))return A.a(d,r)
if(d[r]===0)s=r
return s},
bX(a,b,c,d){var s,r,q,p,o,n,m=B.c.S(c,16),l=B.c.W(c,16),k=16-l,j=B.c.aj(1,l)-1,i=a.length
if(!(m>=0&&m<i))return A.a(a,m)
s=B.c.bG(a[m],l)
r=b-m-1
for(q=d.$flags|0,p=0;p<r;++p){o=p+m+1
if(!(o<i))return A.a(a,o)
n=a[o]
o=B.c.aj((n&j)>>>0,k)
q&2&&A.a8(d)
if(!(p<d.length))return A.a(d,p)
d[p]=(o|s)>>>0
s=B.c.bG(n,l)}q&2&&A.a8(d)
if(!(r>=0&&r<d.length))return A.a(d,r)
d[r]=s},
aJ(a,b,c,d){var s,r,q,p,o=b-d
if(o===0)for(s=b-1,r=a.length,q=c.length;s>=0;--s){if(!(s<r))return A.a(a,s)
p=a[s]
if(!(s<q))return A.a(c,s)
o=p-c[s]
if(o!==0)return o}return o},
bo(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.a(a,o)
n=a[o]
if(!(o<r))return A.a(c,o)
p+=n+c[o]
q&2&&A.a8(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=p>>>16}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.a(a,o)
p+=a[o]
q&2&&A.a8(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=p>>>16}q&2&&A.a8(e)
if(!(b>=0&&b<e.length))return A.a(e,b)
e[b]=p},
a5(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.a(a,o)
n=a[o]
if(!(o<r))return A.a(c,o)
p+=n-c[o]
q&2&&A.a8(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=0-(B.c.aI(p,16)&1)}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.a(a,o)
p+=a[o]
q&2&&A.a8(e)
if(!(o<e.length))return A.a(e,o)
e[o]=p&65535
p=0-(B.c.aI(p,16)&1)}},
na(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k
if(a===0)return
for(s=b.length,r=d.length,q=d.$flags|0,p=0;--f,f>=0;e=l,c=o){o=c+1
if(!(c<s))return A.a(b,c)
n=b[c]
if(!(e>=0&&e<r))return A.a(d,e)
m=a*n+d[e]+p
l=e+1
q&2&&A.a8(d)
d[e]=m&65535
p=B.c.S(m,65536)}for(;p!==0;e=l){if(!(e>=0&&e<r))return A.a(d,e)
k=d[e]+p
l=e+1
q&2&&A.a8(d)
d[e]=k&65535
p=B.c.S(k,65536)}},
qM(a,b,c){var s,r,q,p=b.length
if(!(c>=0&&c<p))return A.a(b,c)
s=b[c]
if(s===a)return 65535
r=c-1
if(!(r>=0&&r<p))return A.a(b,r)
q=B.c.au((s<<16|b[r])>>>0,a)
if(q>65535)return 65535
return q},
qL(b4,b5,b6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7="must not be zero",a8=b4.c,a9=b5.c,b0=a8>a9?a8:a9,b1=A.cU(b4.b,0,a8,b0),b2=A.cU(b5.b,0,a9,b0),b3=0
if(a8===0)throw A.c(A.fp(0,"this",a7))
if(a9===0)throw A.c(A.fp(0,"other",a7))
if(a8===1){if(0>=b1.length)return A.a(b1,0)
s=b1[0]===1}else s=!1
if(!s)if(a9===1){if(0>=b2.length)return A.a(b2,0)
s=b2[0]===1}else s=!1
else s=!0
if(s)return $.o()
if(0>=b1.length)return A.a(b1,0)
s=b2.length
for(;;){if((b1[0]&1)===0){if(0>=s)return A.a(b2,0)
r=(b2[0]&1)===0}else r=!1
if(!r)break
A.bX(b1,a8,1,b1)
A.bX(b2,a9,1,b2);++b3}if(b3>=16){q=B.c.S(b3,16)
a8-=q
a9-=q
p=b0-q}else p=b0
if(0>=s)return A.a(b2,0)
if((b2[0]&1)===1){o=a9
a9=a8
a8=o
o=b2
b2=b1
b1=o}n=A.cU(b1,0,a8,b0)
m=A.cU(b2,0,a9,b0+2)
if(0>=b1.length)return A.a(b1,0)
l=(b1[0]&1)===0
k=p+1
j=k+2
i=$.ov()
if(l){i=new Uint16Array(j)
if(0>=j)return A.a(i,0)
i[0]=1
h=new Uint16Array(j)}else h=i
g=new Uint16Array(j)
f=new Uint16Array(j)
if(0>=j)return A.a(f,0)
f[0]=1
for(s=n.length,r=m.length,e=h.length,d=i.length,c=!1,b=!1,a=!1,a0=!1;;){if(0>=s)return A.a(n,0)
while((n[0]&1)===0){A.bX(n,p,1,n)
if(l){if(0>=d)return A.a(i,0)
if((i[0]&1)!==1){if(0>=j)return A.a(g,0)
a1=(g[0]&1)===1}else a1=!0
if(a1){if(c){if(!(p>=0&&p<d))return A.a(i,p)
c=i[p]!==0||A.aJ(i,p,b2,p)>0
if(c)A.a5(i,k,b2,p,i)
else A.a5(b2,p,i,p,i)}else A.bo(i,k,b2,p,i)
if(a)A.bo(g,k,b1,p,g)
else{if(!(p>=0&&p<j))return A.a(g,p)
a1=g[p]!==0||A.aJ(g,p,b1,p)>0
if(a1)A.a5(g,k,b1,p,g)
else A.a5(b1,p,g,p,g)
a=!a1}}A.bX(i,k,1,i)}else{if(0>=j)return A.a(g,0)
if((g[0]&1)===1)if(a)A.bo(g,k,b1,p,g)
else{if(!(p>=0&&p<j))return A.a(g,p)
a1=g[p]!==0||A.aJ(g,p,b1,p)>0
if(a1)A.a5(g,k,b1,p,g)
else A.a5(b1,p,g,p,g)
a=!a1}}A.bX(g,k,1,g)}if(0>=r)return A.a(m,0)
while((m[0]&1)===0){A.bX(m,p,1,m)
if(l){if(0>=e)return A.a(h,0)
if((h[0]&1)===1||(f[0]&1)===1){if(b){if(!(p>=0&&p<e))return A.a(h,p)
b=h[p]!==0||A.aJ(h,p,b2,p)>0
if(b)A.a5(h,k,b2,p,h)
else A.a5(b2,p,h,p,h)}else A.bo(h,k,b2,p,h)
if(a0)A.bo(f,k,b1,p,f)
else{if(!(p>=0&&p<j))return A.a(f,p)
a1=f[p]!==0||A.aJ(f,p,b1,p)>0
if(a1)A.a5(f,k,b1,p,f)
else A.a5(b1,p,f,p,f)
a0=!a1}}A.bX(h,k,1,h)}else if((f[0]&1)===1)if(a0)A.bo(f,k,b1,p,f)
else{if(!(p>=0&&p<j))return A.a(f,p)
a1=f[p]!==0||A.aJ(f,p,b1,p)>0
if(a1)A.a5(f,k,b1,p,f)
else A.a5(b1,p,f,p,f)
a0=!a1}A.bX(f,k,1,f)}if(A.aJ(n,p,m,p)>=0){A.a5(n,p,m,p,n)
if(l)if(c===b){a2=A.aJ(i,k,h,k)
if(a2>0)A.a5(i,k,h,k,i)
else{A.a5(h,k,i,k,i)
c=!c&&a2!==0}}else A.bo(i,k,h,k,i)
if(a===a0){a3=A.aJ(g,k,f,k)
if(a3>0)A.a5(g,k,f,k,g)
else{A.a5(f,k,g,k,g)
a=!a&&a3!==0}}else A.bo(g,k,f,k,g)}else{A.a5(m,p,n,p,m)
if(l)if(b===c){a4=A.aJ(h,k,i,k)
if(a4>0)A.a5(h,k,i,k,h)
else{A.a5(i,k,h,k,h)
b=!b&&a4!==0}}else A.bo(h,k,i,k,h)
if(a0===a){a5=A.aJ(f,k,g,k)
if(a5>0)A.a5(f,k,g,k,f)
else{A.a5(g,k,f,k,f)
a0=!a0&&a5!==0}}else A.bo(f,k,g,k,f)}a6=p
for(;;){if(a6>0){a1=a6-1
if(!(a1<s))return A.a(n,a1)
a1=n[a1]===0}else a1=!1
if(!a1)break;--a6}if(a6===0)break}s=A.aF(b3>0?A.lC(m,p,b3,m):p,m)
return new A.ab(!1,m,s)},
eh(a,b,c){var s
A.I(a)
A.nw(c)
t.ck.a(b)
s=A.bk(a,c)
if(s!=null)return s
if(b!=null)return b.$1(a)
throw A.c(A.dd(a,null))},
oW(a,b){a=A.al(a,new Error())
if(a==null)a=A.cv(a)
a.stack=b.k(0)
throw a},
aA(a,b,c,d){var s,r=c?J.ml(a,d):J.p1(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
bh(a,b,c){var s,r=A.d([],c.h("F<0>"))
for(s=J.bu(a);s.q();)B.b.l(r,c.a(s.gD()))
if(b)return r
r.$flags=1
return r},
L(a,b){var s,r=A.d([],b.h("F<0>"))
for(s=a.gC(a);s.q();)B.b.l(r,s.gD())
return r},
la(a,b,c){var s,r=J.ml(a,c)
for(s=0;s<a;++s)B.b.u(r,s,b.$1(s))
return r},
cb(a,b){var s=A.bh(a,!1,b)
s.$flags=3
return s},
l(a,b){return new A.ca(a,A.l6(a,!1,b,!1,!1,""))},
lp(a,b,c){var s=J.bu(b)
if(!s.q())return a
if(c.length===0){do a+=A.r(s.gD())
while(s.q())}else{a+=A.r(s.gD())
while(s.q())a=a+c+A.r(s.gD())}return a},
qh(){return A.eg(new Error())},
oU(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
mj(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
ev(a){if(a>=10)return""+a
return"0"+a},
ex(a){if(typeof a=="number"||A.kv(a)||a==null)return J.b2(a)
if(typeof a=="string")return JSON.stringify(a)
return A.mI(a)},
oX(a,b){A.ee(a,"error",t.K)
A.ee(b,"stackTrace",t.l)
A.oW(a,b)},
em(a){return new A.el(a)},
aG(a,b){return new A.b3(!1,null,b,a)},
fp(a,b,c){return new A.b3(!0,a,b,c)},
oI(a,b,c){return a},
lm(a,b){return new A.dz(null,null,!0,a,b,"Value not in range")},
aw(a,b,c,d,e){return new A.dz(b,c,!0,a,d,"Invalid value")},
pT(a,b,c,d){if(a<b||a>c)throw A.c(A.aw(a,b,c,d,null))
return a},
pS(a,b,c){if(0>a||a>c)throw A.c(A.aw(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.c(A.aw(b,a,c,"end",null))
return b}return c},
eQ(a,b){if(a<0)throw A.c(A.aw(a,0,null,b,null))
return a},
h9(a,b,c,d){return new A.ey(b,!0,a,d,"Index out of range")},
cT(a){return new A.dH(a)},
n2(a){return new A.f_(a)},
ck(a){return new A.cP(a)},
ag(a){return new A.et(a)},
p_(a){return new A.js(a)},
dd(a,b){return new A.T(a,b)},
p0(a,b,c){var s,r
if(A.lZ(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.d([],t.s)
B.b.l($.aT,a)
try{A.rK(a,s)}finally{if(0>=$.aT.length)return A.a($.aT,-1)
$.aT.pop()}r=A.lp(b,t.hf.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
l5(a,b,c){var s,r
if(A.lZ(a))return b+"..."+c
s=new A.bm(b)
B.b.l($.aT,a)
try{r=s
r.a=A.lp(r.a,a,", ")}finally{if(0>=$.aT.length)return A.a($.aT,-1)
$.aT.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
rK(a,b){var s,r,q,p,o,n,m,l=a.gC(a),k=0,j=0
for(;;){if(!(k<80||j<3))break
if(!l.q())return
s=A.r(l.gD())
B.b.l(b,s)
k+=s.length+2;++j}if(!l.q()){if(j<=5)return
if(0>=b.length)return A.a(b,-1)
r=b.pop()
if(0>=b.length)return A.a(b,-1)
q=b.pop()}else{p=l.gD();++j
if(!l.q()){if(j<=4){B.b.l(b,A.r(p))
return}r=A.r(p)
if(0>=b.length)return A.a(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gD();++j
for(;l.q();p=o,o=n){n=l.gD();++j
if(j>100){for(;;){if(!(k>75&&j>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2;--j}B.b.l(b,"...")
return}}q=A.r(p)
r=A.r(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
for(;;){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.a(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.b.l(b,m)
B.b.l(b,q)
B.b.l(b,r)},
mt(a,b,c,d,e){return new A.c4(a,b.h("@<0>").L(c).L(d).L(e).h("c4<1,2,3,4>"))},
dv(a,b,c,d){var s
if(B.i===c){s=J.aM(a)
b=J.aM(b)
return A.j5(A.bE(A.bE($.fn(),s),b))}if(B.i===d){s=J.aM(a)
b=J.aM(b)
c=J.aM(c)
return A.j5(A.bE(A.bE(A.bE($.fn(),s),b),c))}s=J.aM(a)
b=J.aM(b)
c=J.aM(c)
d=J.aM(d)
d=A.j5(A.bE(A.bE(A.bE(A.bE($.fn(),s),b),c),d))
return d},
pA(a){var s,r,q=$.fn()
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.M)(a),++r)q=A.bE(q,J.aM(a[r]))
return A.j5(q)},
ab:function ab(a,b,c){this.a=a
this.b=b
this.c=c},
ji:function ji(){},
jj:function jj(){},
jk:function jk(a,b){this.a=a
this.b=b},
jl:function jl(a){this.a=a},
c5:function c5(a,b,c){this.a=a
this.b=b
this.c=c},
jq:function jq(){},
a3:function a3(){},
el:function el(a){this.a=a},
bF:function bF(){},
b3:function b3(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dz:function dz(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
ey:function ey(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
dH:function dH(a){this.a=a},
f_:function f_(a){this.a=a},
cP:function cP(a){this.a=a},
et:function et(a){this.a=a},
dC:function dC(){},
js:function js(a){this.a=a},
T:function T(a,b){this.a=a
this.b=b},
ez:function ez(){},
m:function m(){},
a0:function a0(a,b,c){this.a=a
this.b=b
this.$ti=c},
aD:function aD(){},
z:function z(){},
ff:function ff(){},
bm:function bm(a){this.a=a},
hW:function hW(a){this.a=a},
re(a,b,c){t.e.a(a)
if(A.K(c)>=1)return a.$1(b)
return a.$0()},
nQ(a){return a==null||A.kv(a)||typeof a=="number"||typeof a=="string"||t.gj.b(a)||t.gc.b(a)||t.go.b(a)||t.dQ.b(a)||t.h7.b(a)||t.an.b(a)||t.ai.b(a)||t.h4.b(a)||t.gN.b(a)||t.dI.b(a)||t.fd.b(a)},
o2(a){if(A.nQ(a))return a
return new A.kH(new A.cW(t.hg)).$1(a)},
tK(a,b){var s=new A.b_($.ak,b.h("b_<0>")),r=new A.dJ(s,b.h("dJ<0>"))
a.then(A.d2(new A.kN(r,b),1),A.d2(new A.kO(r),1))
return s},
nP(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
o_(a){if(A.nP(a))return a
return new A.kz(new A.cW(t.hg)).$1(a)},
kH:function kH(a){this.a=a},
kN:function kN(a,b){this.a=a
this.b=b},
kO:function kO(a){this.a=a},
kz:function kz(a){this.a=a},
oL(a){var s,r,q,p,o,n=A.d([],t.s)
for(s=a.length,r=0,q=0,p=0;p<s;++p){o=a[p]
if(o==="("||o==="[")++r
if(o===")"||o==="]")--r
if(o===","&&r===0){B.b.l(n,B.a.F(a,q,p))
q=p+1}}B.b.l(n,B.a.M(a,q))
return n},
l3(a){var s,r=B.a.p(a),q=A.l("\\s*\\+\\s*-?0(\\.0*)?\\s*\\*?\\s*I\\b",!0)
r=A.A(r,q,"")
q=A.l("\\bI\\b",!0)
s=A.am(A.A(r,q,""))
if(s==null)return null
if(isNaN(s)||s==1/0||s==-1/0)return null
return s},
bw(a){var s,r,q
if(Math.abs(a-B.f.b6(a))<1e-9&&Math.abs(a)<1e15)return B.c.k(B.f.bO(a))
s=B.f.bQ(a,10)
if(B.a.J(s,".")){r=A.l("0+$",!0)
r=A.A(s,r,"")
q=A.l("\\.$",!0)
r=A.A(r,q,"")}else r=s
return r},
dn:function dn(a,b){this.a=a
this.b=b},
eo:function eo(){this.b=this.a=null
this.c=!1},
fv:function fv(a){this.a=a},
fw:function fw(a){this.a=a},
fy:function fy(a){this.a=a},
fz:function fz(a){this.a=a},
fx:function fx(a){this.a=a},
fG:function fG(a){this.a=a},
fu:function fu(a,b){this.a=a
this.b=b},
fI:function fI(a,b,c){this.a=a
this.b=b
this.c=c},
fH:function fH(a){this.a=a},
fs:function fs(a,b){this.a=a
this.b=b},
ft:function ft(a,b){this.a=a
this.b=b},
fA:function fA(a){this.a=a},
fB:function fB(a){this.a=a},
fC:function fC(a,b){this.a=a
this.b=b},
fD:function fD(a,b){this.a=a
this.b=b},
fF:function fF(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fE:function fE(a){this.a=a},
fq:function fq(a){this.a=a},
fr:function fr(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
oR(a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null,a4=!0
if(a5.length<=512)if(A.ed(a5)){e=A.l("\\bI\\b",!0)
if(e.b.test(a5))if(a6!=="I"){a4=A.l("^[A-Za-z_][A-Za-z_0-9]*$",!0)
a4=!a4.b.test(a6)}}if(a4)return a3
try{a4={}
e=t.s
s=A.d(a5.split("="),e)
if(J.S(s)>2)return a3
r=J.S(s)===2?"("+J.aL(s,0)+")-("+J.aL(s,1)+")":a5
a4.a=0
q=new A.fN()
p=new A.fM(q)
o=new A.fO(a4,a6,q,p)
n=o.$2(new A.bW(r).aN(),0)
if(J.S(n)===1){a4=J.mc(n)
d=$.p()
c=a4.a.a.j(0,d)
if(c===0)a4=a4.b.a.j(0,d)===0
else a4=!1
a4=a4?a3:A.d([],e)
return a4}m=J.aL(n,1)
l=J.aL(n,0)
if(J.S(n)===2){a4=l
d=a4.a
c=d.a.n(0)
a4=a4.b
b=a4.a.n(0)
e=A.d([new A.U(A.W(new A.f(c,d.b)),A.W(new A.f(b,a4.b))).i(0,m.aS()).k(0)],e)
return e}k=J.aL(n,2)
a4=J.m6(m,m)
d=A.C(4)
c=$.o()
b=$.J()
d=new A.U(A.W(new A.f(d,c)),A.W(b)).i(0,k).i(0,l)
a=d.a
a0=a.a.n(0)
d=d.b
a1=d.a.n(0)
j=a4.A(0,new A.U(A.W(new A.f(a0,a.b)),A.W(new A.f(a1,d.b))))
i=new A.U(A.W(new A.f(A.C(2),c)),A.W(b)).i(0,k)
h=j.cQ()
if(h!=null){a4=m
d=a4.a
c=d.a.n(0)
a4=a4.b
b=a4.a.n(0)
d=A.W(new A.f(c,d.b))
a4=A.W(new A.f(b,a4.b))
b=h
c=b.a
a=c.a.n(0)
b=b.b
a0=b.a.n(0)
g=new A.U(d,a4).A(0,new A.U(A.W(new A.f(a,c.b)),A.W(new A.f(a0,b.b)))).i(0,i.aS()).k(0)
b=m
a0=b.a
c=a0.a.n(0)
b=b.b
a=b.a.n(0)
f=new A.U(A.W(new A.f(c,a0.b)),A.W(new A.f(a,b.b))).A(0,h).i(0,i.aS()).k(0)
a4=J.N(g,f)?A.d([g],e):A.d([g,f],e)
return a4}a4=m
d=a4.a
c=d.a.n(0)
a4=a4.b
b=a4.a.n(0)
a4=new A.U(A.W(new A.f(c,d.b)),A.W(new A.f(b,a4.b))).k(0)
b=A.r(j)
d=A.r(i)
c=m
a=c.a
a0=a.a.n(0)
c=c.b
a1=c.a.n(0)
e=A.d(["(("+a4+")-sqrt(("+b+")))/("+d+")","(("+new A.U(A.W(new A.f(a0,a.b)),A.W(new A.f(a1,c.b))).k(0)+")+sqrt(("+A.r(j)+")))/("+A.r(i)+")"],e)
return e}catch(a2){return a3}},
qP(a,b){return new A.U(A.W(a),A.W(b))},
nc(a){var s=A.C(a),r=$.o(),q=$.J()
return new A.U(A.W(new A.f(s,r)),A.W(q))},
W(a){var s=a.a
if((s.a?s.n(0):s).gt(0)+a.b.gt(0)>4096)throw A.c(B.n)
return a},
aQ(a,b){var s,r=a.a
r=(r.a?r.n(0):r).gt(0)
s=b.a
if(r+(s.a?s.n(0):s).gt(0)>4096||a.b.gt(0)+b.b.gt(0)>4096)throw A.c(B.er)
return A.W(a.i(0,b))},
b8(a,b){var s,r=b.b,q=$.o()
A.aQ(a,A.k(r,q))
s=a.b
A.aQ(b,A.k(s,q))
if(s.gt(0)+r.gt(0)>4096)throw A.c(B.e9)
return A.W(a.A(0,b))},
lE(a){var s,r,q,p=A.aX("sqrt("+a.k(0)+")")
if(p==null)return null
s=p.split("/")
r=s.length
if(0>=r)return A.a(s,0)
q=A.ae(s[0],null)
if(r===1)r=$.o()
else{if(1>=r)return A.a(s,1)
r=A.ae(s[1],null)}return A.k(q,r)},
fN:function fN(){},
fM:function fM(a){this.a=a},
fO:function fO(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
U:function U(a,b){this.a=a
this.b=b},
fQ(a){var s,r
A.bs(a)
if(a===B.f.b6(a)&&Math.abs(a)<1e12)return B.c.k(B.f.ai(a))
s=B.f.cG(a,6)
if(B.a.J(s,".")){r=A.l("0+$",!0)
s=A.A(s,r,"")
r=A.l("\\.$",!0)
s=A.A(s,r,"")}return s},
ta(a){var s,r=a.length
if(r===0||B.b.X(a,new A.ky(r)))return null
if(r===1){if(0>=a.length)return A.a(a,0)
s=a[0]
if(0>=s.length)return A.a(s,0)
return new A.cE(A.d([new A.az(s[0],0)],t.J),null)}if(r===2)return A.ri(a)
return A.rj(a)},
ri(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=a.length
if(0>=d)return A.a(a,0)
s=a[0]
r=s.length
if(0>=r)return A.a(s,0)
q=s[0]
if(1>=r)return A.a(s,1)
p=s[1]
if(1>=d)return A.a(a,1)
d=a[1]
s=d.length
if(0>=s)return A.a(d,0)
o=d[0]
if(1>=s)return A.a(d,1)
n=d[1]
m=q+n
l=m*m-4*(q*n-p*o)
if(l>=0){k=Math.sqrt(l)
j=(m+k)/2
i=(m-k)/2
h=A.d([],t.gy)
for(d=[j,i],g=0;g<2;++g)B.b.l(h,A.rk(a,d[g]))
d=A.d([new A.az(j,0),new A.az(i,0)],t.J)
return new A.cE(d,h.length===2?h:null)}else{f=m/2
e=Math.sqrt(-l)/2
return new A.cE(A.d([new A.az(f,e),new A.az(f,-e)],t.J),null)}},
rk(a,b){var s,r,q,p,o,n,m,l=a.length
if(0>=l)return A.a(a,0)
s=a[0]
r=s.length
if(0>=r)return A.a(s,0)
q=s[0]-b
if(1>=r)return A.a(s,1)
p=s[1]
if(1>=l)return A.a(a,1)
l=a[1]
s=l.length
if(0>=s)return A.a(l,0)
o=l[0]
if(1>=s)return A.a(l,1)
n=l[1]-b
if(Math.abs(q)>1e-10||Math.abs(p)>1e-10){if(Math.abs(p)>1e-10){m=Math.sqrt(q*q+p*p)
return A.d([-p/m,q/m],t.n)}return A.d([0,1],t.n)}if(Math.abs(o)>1e-10||Math.abs(n)>1e-10){if(Math.abs(n)>1e-10){m=Math.sqrt(o*o+n*n)
return A.d([-n/m,o/m],t.n)}return A.d([0,1],t.n)}return A.d([1,0],t.n)},
rj(a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=a6.length,a5=A.rr(a6)
for(s=a4-1,r=t.V,q=0;q<200;++q){o=a5.length
n=1
for(;;){if(!(n<a4)){p=!0
break}if(!(n<o))return A.a(a5,n)
m=a5[n]
l=n-1
k=m.length
if(!(l<k))return A.a(m,l)
j=m[l]
if(!(n<k))return A.a(m,n)
m=m[n]
if(!(l<o))return A.a(a5,l)
k=a5[l]
if(!(l<k.length))return A.a(k,l)
if(Math.abs(j)>1e-12*(Math.abs(m)+Math.abs(k[l])+1e-30)){p=!1
break}++n}if(p)break
if(!(s>=0&&s<o))return A.a(a5,s)
o=a5[s]
if(!(s<o.length))return A.a(o,s)
i=o[s]
for(n=0;n<a4;++n){if(!(n<a5.length))return A.a(a5,n)
o=a5[n]
if(!(n<o.length))return A.a(o,n)
B.b.u(o,n,o[n]-i)}h=A.aA(s,0,!1,r)
g=A.aA(s,0,!1,r)
for(n=0;n<s;n=f){o=a5.length
if(!(n<o))return A.a(a5,n)
m=a5[n]
if(!(n<m.length))return A.a(m,n)
m=m[n]
f=n+1
if(!(f<o))return A.a(a5,f)
o=a5[f]
if(!(n<o.length))return A.a(o,n)
o=o[n]
e=Math.sqrt(m*m+o*o)
if(e<1e-30){B.b.u(h,n,1)
B.b.u(g,n,0)
continue}if(!(n<a5.length))return A.a(a5,n)
o=a5[n]
if(!(n<o.length))return A.a(o,n)
B.b.u(h,n,o[n]/e)
if(!(f<a5.length))return A.a(a5,f)
o=a5[f]
if(!(n<o.length))return A.a(o,n)
B.b.u(g,n,o[n]/e)
for(d=0;d<a4;++d){o=h[n]
m=a5.length
if(!(n<m))return A.a(a5,n)
l=a5[n]
if(!(d<l.length))return A.a(l,d)
k=l[d]
j=g[n]
if(!(f<m))return A.a(a5,f)
m=a5[f]
if(!(d<m.length))return A.a(m,d)
m=m[d]
B.b.u(l,d,o*k+j*m)
if(!(f<a5.length))return A.a(a5,f)
B.b.u(a5[f],d,-j*k+o*m)}}for(n=0;n<s;n=f)for(f=n+1,d=0;d<a4;++d){o=h[n]
if(!(d<a5.length))return A.a(a5,d)
m=a5[d]
l=m.length
if(!(n<l))return A.a(m,n)
k=m[n]
j=g[n]
if(!(f<l))return A.a(m,f)
l=m[f]
B.b.u(m,n,o*k+j*l)
if(!(d<a5.length))return A.a(a5,d)
B.b.u(a5[d],f,-j*k+o*l)}for(n=0;n<a4;++n){if(!(n<a5.length))return A.a(a5,n)
o=a5[n]
if(!(n<o.length))return A.a(o,n)
B.b.u(o,n,o[n]+i)}}c=A.d([],t.J)
for(n=0;n<a4;){f=n+1
if(f<a4){if(!(f<a5.length))return A.a(a5,f)
s=a5[f]
if(!(n<s.length))return A.a(s,n)
s=Math.abs(s[n])>1e-10}else s=!1
r=a5.length
if(s){if(!(n<r))return A.a(a5,n)
s=a5[n]
o=s.length
if(!(n<o))return A.a(s,n)
b=s[n]
if(!(f<o))return A.a(s,f)
a=s[f]
if(!(f<r))return A.a(a5,f)
r=a5[f]
s=r.length
if(!(n<s))return A.a(r,n)
a0=r[n]
if(!(f<s))return A.a(r,f)
a1=r[f]
a2=b+a1
a3=a2*a2-4*(b*a1-a*a0)
if(a3>=0){B.b.l(c,new A.az((a2+Math.sqrt(a3))/2,0))
B.b.l(c,new A.az((a2-Math.sqrt(a3))/2,0))}else{s=a2/2
r=-a3
B.b.l(c,new A.az(s,Math.sqrt(r)/2))
B.b.l(c,new A.az(s,-Math.sqrt(r)/2))}n+=2}else{if(!(n<r))return A.a(a5,n)
s=a5[n]
if(!(n<s.length))return A.a(s,n)
B.b.l(c,new A.az(s[n],0))
n=f}}return new A.cE(c,null)},
rr(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=a.length,d=J.bg(e,t.H)
for(s=t.V,r=0;r<e;++r){if(!(r<a.length))return A.a(a,r)
d[r]=A.bh(a[r],!0,s)}for(q=e-2,p=0;p<q;p=r){for(r=p+1,o=d.length,n=r,m=0;n<e;++n){if(!(n<o))return A.a(d,n)
l=d[n]
if(!(p<l.length))return A.a(l,p)
l=l[p]
m+=l*l}m=Math.sqrt(m)
if(m<1e-30)continue
o=d.length
if(!(r<o))return A.a(d,r)
l=d[r]
if(!(p<l.length))return A.a(l,p)
if(l[p]>0)m=-m
k=A.aA(e,0,!1,s)
if(!(p<l.length))return A.a(l,p)
B.b.u(k,r,l[p]-m)
for(n=p+2;n<e;++n){if(!(n<o))return A.a(d,n)
l=d[n]
if(!(p<l.length))return A.a(l,p)
B.b.u(k,n,l[p])}for(n=r,j=0;n<e;++n){o=k[n]
j+=o*o}if(j<1e-30)continue
i=2/j
for(h=0;h<e;++h){for(o=d.length,n=r,g=0;n<e;++n){l=k[n]
if(!(n<o))return A.a(d,n)
f=d[n]
if(!(h<f.length))return A.a(f,h)
g+=l*f[h]}for(n=r;n<e;++n){if(!(n<d.length))return A.a(d,n)
o=d[n]
if(!(h<o.length))return A.a(o,h)
B.b.u(o,h,o[h]-i*k[n]*g)}}for(n=0;n<e;++n){for(o=d.length,h=r,g=0;h<e;++h){if(!(n<o))return A.a(d,n)
l=d[n]
if(!(h<l.length))return A.a(l,h)
g+=l[h]*k[h]}for(o=i*g,h=r;h<e;++h){if(!(n<d.length))return A.a(d,n)
l=d[n]
if(!(h<l.length))return A.a(l,h)
B.b.u(l,h,l[h]-o*k[h])}}}return d},
cE:function cE(a,b){this.a=a
this.b=b},
fR:function fR(){},
fS:function fS(){},
az:function az(a,b){this.a=a
this.b=b},
ky:function ky(a){this.a=a},
f1:function f1(a,b){this.a=a
this.$ti=b},
aI(a){var s=a.a
if((s.a?s.n(0):s).gt(0)+a.b.gt(0)>4096)throw A.c(B.n)
return a},
l4(a){var s,r,q,p=A.aX(A.bN(a))
if(p==null)return null
s=p.split("/")
r=s.length
if(0>=r)return A.a(s,0)
q=A.ae(s[0],null)
if(r===1)r=$.o()
else{if(1>=r)return A.a(s,1)
r=A.ae(s[1],null)}return A.aI(A.k(q,r))},
oY(a){var s,r,q,p,o,n,m={}
if(a.length<=512){p=A.l("\\bconjugate\\s*\\(",!0)
p=!p.b.test(a)||!A.ed(a)}else p=!0
if(p)return null
m.a=0
s=new A.fV(m,new A.fT(),new A.fU())
try{r=s.$2(new A.bW(a).aN(),0)
m=r.b
p=$.p()
m=m.a.j(0,p)
if(m===0){m=r.a.k(0)
return m}m=r.b
o=m.a
if(o.a)o=o.n(0)
q=new A.f(o,m.b).k(0)+"*I"
m=r.a.a.j(0,p)
if(m===0){m=r.b.a.gE(0)<0?"-":""
p=A.r(q)
return m+p}m=r.a.k(0)
p=r.b.a.gE(0)<0?"-":"+"
o=A.r(q)
return m+p+o}catch(n){return null}},
oZ(a){var s,r,q,p,o,n,m,l=null
if(a.length<=512)o=!B.a.J(a,"^")&&!B.a.J(a,"**")||!A.ed(a)
else o=!0
if(o)return l
try{o={}
o.a=0
n=o.b=!1
s=new A.fX(o)
r=new A.fW()
q=s.$2(new A.bW(a).aN(),0)
p=o.b?r.$1(q):l
o=(p!=null?p.length<=4096:n)?p:l
return o}catch(m){return l}},
fT:function fT(){},
fU:function fU(){},
fV:function fV(a,b,c){this.a=a
this.b=b
this.c=c},
fX:function fX(a){this.a=a},
fY:function fY(a,b){this.a=a
this.b=b},
fZ:function fZ(a,b){this.a=a
this.b=b},
h_:function h_(a,b){this.a=a
this.b=b},
fW:function fW(){},
aX(a){var s,r,q,p,o=null,n=a.length
if(n<=512){q=A.l("^[\\d.\\s+*/%^!()\\-absqrtfloorceilingE]+$",!0)
q=!q.b.test(a)}else q=!0
if(q)return o
try{s=new A.jp(a)
r=s.aZ()
s.bT()
n=s.b===n?J.b2(r):o
return n}catch(p){n=A.ac(p)
if(n instanceof A.Y)return o
else if(n instanceof A.b3)return o
else throw p}},
Y:function Y(){},
jp:function jp(a){var _=this
_.a=a
_.d=_.c=_.b=0},
bf:function bf(a,b){this.a=a
this.b=b},
b:function b(){},
j:function j(a,b){this.a=a
this.c=b},
tM(a,b){var s=a.a,r=a.$ti.h("4?"),q=A.I(r.a(s.m(0,"expression"))),p=J.ma(t._.a(r.a(s.m(0,"xs"))),t.o)
if(J.S(p.a)>501)throw A.c(A.aG("Too many table rows",null))
s=p.$ti
r=s.h("t<P.E,n<h?>>")
s=A.L(new A.t(p,s.h("n<h?>(P.E)").a(new A.kR(A.au(q),b,q)),r),r.h("D.E"))
return s},
kR:function kR(a,b,c){this.a=a
this.b=b
this.c=c},
tL(a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=a6.a,d=a6.$ti.h("4?"),c=A.aK(d.a(e.m(0,"xMin"))),b=A.aK(d.a(e.m(0,"xMax"))),a=A.aK(d.a(e.m(0,"yMin"))),a0=A.aK(d.a(e.m(0,"yMax"))),a1=J.N(d.a(e.m(0,"coarse")),!0),a2=A.aK(d.a(e.m(0,"width"))),a3=B.c.dV(B.f.cv(a2/(a1?4:1)),80,2400),a4=A.d([],t.dc),a5=A.d([],t.cp)
for(a2=J.ma(t._.a(d.a(e.m(0,"functions"))),t.N),s=a2.$ti,a2=new A.b6(a2,a2.gB(0),s.h("b6<P.E>")),r=t.fn,q=b-c,p=t.q,s=s.h("P.E"),o=!a1;a2.q();){n=a2.d
if(n==null)n=s.a(n)
m=new A.kS(A.au(n),a7,n)
l=A.d([],p)
for(k=0;k<=a3;++k){j=c+q*k/a3
i=m.$1(j)
n=i!=null
h=n&&isFinite(i)?i:0
B.b.l(l,new A.aR(n&&isFinite(i),j,h))}B.b.l(a4,l)
B.b.l(a5,J.N(d.a(e.m(0,"annotations")),!0)&&o?A.rL(l,m,A.aK(d.a(e.m(0,"scale")))):A.d([],r))}g=A.d([],p)
f=A.d([],t.B)
switch(d.a(e.m(0,"mode"))){case"parametric":a2=A.I(d.a(e.m(0,"parametricX")))
s=A.I(d.a(e.m(0,"parametricY")))
r=A.bs(d.a(e.m(0,"tMin")))
e=A.bs(d.a(e.m(0,"tMax")))
g=A.pC(a2,s,a1?100:400,e,r)
break
case"polar":a2=A.I(d.a(e.m(0,"polarR")))
e=A.bs(d.a(e.m(0,"thetaMax")))
g=A.pD(a2,a1?180:720,e)
break
case"implicit":e=A.I(d.a(e.m(0,"implicitF")))
f=A.pB(e,a1?35:110,b,c,a0,a)
break
case"vectorField":a2=A.I(d.a(e.m(0,"vfU")))
e=A.I(d.a(e.m(0,"vfV")))
f=A.pE(a2,e,a1?10:20,b,c,a0,a)
break}return new A.h2(a4,a5,g,f)},
rL(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=A.d([],t.fn),a3=Math.abs(B.b.gR(a4).b-B.b.gP(a4).b)/a4.length/100
for(s=50/a6,r=1;r<a4.length;++r){q=a4[r-1]
p=a4[r]
if(!q.a||!p.a||Math.abs(q.c-p.c)>s)continue
o=q.c
n=o===0
if(n||J.aN(o)!==J.aN(p.c)){m=q.b
l=p.b
if(n)k=m
else{n=p.c
if(n===0)k=l
else for(j=o,i=0;k=null,i<40;++i){h=(m+l)/2
g=a5.$1(h)
if(g==null||!isFinite(g))break
f=Math.abs(g)
if(f<1e-8){k=h
break}if(Math.abs(l-m)<a3){k=f<Math.max(Math.abs(o),Math.abs(n))*0.01?h:null
break}if(J.aN(g)===J.aN(j)){j=g
m=h}else l=h}}if(k!=null)n=a2.length===0||Math.abs(B.b.gR(a2).b-k)>a3
else n=!1
if(n)B.b.l(a2,new A.cu("root",k,0))}n=r+1
if(n>=a4.length)continue
e=a4[n]
if(!e.a||Math.abs(e.c-p.c)>s)continue
n=p.c
d=n-o
f=e.c
c=f-n
if(d===0||c===0||J.aN(d)===J.aN(c))continue
b=o-2*n+f
n=p.b
a=q.b
a0=n+0.5*(o-f)/b*(n-a)
a1=a5.$1(a0)
if(a1!=null&&isFinite(a1)&&a0>=a&&a0<=e.b)B.b.l(a2,new A.cu(b>0?"min":"max",a0,a1))}if(B.b.gR(a4).a&&B.b.gR(a4).c===0)B.b.l(a2,new A.cu("root",B.b.gR(a4).b,0))
return a2},
tN(a,b){var s,r=a.a,q=a.$ti.h("4?"),p=A.I(q.a(r.m(0,"expression"))),o=A.aK(q.a(r.m(0,"range"))),n=A.K(q.a(r.m(0,"grid"))),m=A.au(p),l=n+1,k=J.bg(l,t.H)
for(r=t.V,s=0;s<l;++s)k[s]=A.la(l,new A.kT(o,s,n,m,b,p),r)
return k},
h2:function h2(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
h5:function h5(){},
h4:function h4(){},
h6:function h6(){},
h3:function h3(){},
h7:function h7(){},
h8:function h8(){},
kS:function kS(a,b,c){this.a=a
this.b=b
this.c=c},
kT:function kT(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
p4(b7,b8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4=null,b5=b8.length,b6=!0
if(b5!==0)if(b5<=16){b5=b7.length
b5=b5===0||b5>32||A.p6(b8,A.H(b8).c).a!==b8.length||B.b.X(b8,new A.hh())}else b5=b6
else b5=b6
if(b5)return"Error: linsolve requires 1\u201316 distinct symbols and 1\u201332 equations"
s=A.d([],t.eu)
for(b5=b7.length,b6=t.G,r=0;r<b7.length;b7.length===b5||(0,A.M)(b7),++r){q=b7[r]
if(q.length>512)return b4
p=q.split("=")
o=p.length
if(o>2)return b4
n=A.lh(o===2?"("+p[0]+")-("+p[1]+")":q)
if(n==null||n.gbR()>1||B.b.X(n.a,new A.hi(b8)))return b4
o=b8.length+1
m=A.aA(o,$.J(),!1,b6)
for(l=n.gae(),k=l.$ti,l=new A.af(l.a(),k.h("af<1>")),j=n.a,k=k.c;l.q();){i=l.b
if(i==null)i=k.a(i)
h=i.a
g=i.b
i=g.a
if(i.gt(0)>4096||g.b.gt(0)>4096)return b4
f=J.oG(h,new A.hj())
e=g.b
if(f<0){d=B.b.gR(m)
c=d.b
B.b.sR(m,A.k(d.a.i(0,e).G(0,i.i(0,c)),c.i(0,e)))}else{if(!(f<j.length))return A.a(j,f)
b=B.b.ao(b8,j[f])
if(!(b>=0&&b<o))return A.a(m,b)
d=m[b]
c=d.b
B.b.u(m,b,A.k(d.a.i(0,e).A(0,i.i(0,c)),c.i(0,e)))}}B.b.l(s,m)}a=A.d([],t.t)
a0=0
b=0
for(;;){if(!(b<b8.length&&a0<s.length))break
A:{a1=a0
for(;;){if(a1<s.length){b5=s[a1]
if(!(b<b5.length))return A.a(b5,b)
b5=b5[b].a.j(0,$.p())===0}else b5=!1
if(!b5)break;++a1}b5=s.length
if(a1===b5)break A
if(!(a0<b5))return A.a(s,a0)
a2=s[a0]
if(!(a1<b5))return A.a(s,a1)
s[a0]=s[a1]
s[a1]=a2
b5=s[a0]
if(!(b<b5.length))return A.a(b5,b)
a3=b5[b]
for(b5=a3.b,o=a3.a,a4=b;a4<=b8.length;++a4){if(!(a0<s.length))return A.a(s,a0)
l=s[a0]
if(!(a4<l.length))return A.a(l,a4)
if(l[a4].a.gt(0)+b5.gt(0)<=16384){if(!(a0<s.length))return A.a(s,a0)
l=s[a0]
if(!(a4<l.length))return A.a(l,a4)
l=l[a4].b.gt(0)+o.gt(0)>16384}else l=!0
if(l)return b4
if(!(a0<s.length))return A.a(s,a0)
l=s[a0]
if(!(a4<l.length))return A.a(l,a4)
k=l[a4]
B.b.u(l,a4,A.k(k.a.i(0,b5),k.b.i(0,o)))}for(a5=0;a5<s.length;++a5){if(a5!==a0){b5=s[a5]
if(!(b<b5.length))return A.a(b5,b)
b5=b5[b].a.j(0,$.p())===0}else b5=!0
if(b5)continue
if(!(a5<s.length))return A.a(s,a5)
b5=s[a5]
if(!(b<b5.length))return A.a(b5,b)
a6=b5[b]
for(b5=a6.a,o=a6.b,a4=b;a4<=b8.length;++a4){if(!(a0<s.length))return A.a(s,a0)
l=s[a0]
if(!(a4<l.length))return A.a(l,a4)
a7=l[a4]
l=a7.a
if(b5.gt(0)+l.gt(0)>16384||o.gt(0)+a7.b.gt(0)>16384)return b4
a8=A.k(b5.i(0,l),o.i(0,a7.b))
if(!(a5<s.length))return A.a(s,a5)
l=s[a5]
if(!(a4<l.length))return A.a(l,a4)
a9=l[a4]
l=a9.a
k=a8.b
if(l.gt(0)+k.gt(0)+1<=16384){j=a9.b
j=a8.a.gt(0)+j.gt(0)+1>16384||j.gt(0)+k.gt(0)>16384}else j=!0
if(j)return b4
if(!(a5<s.length))return A.a(s,a5)
j=a9.b
B.b.u(s[a5],a4,A.k(l.i(0,k).G(0,a8.a.i(0,j)),j.i(0,k)))}}B.b.l(a,b);++a0}++b}if(B.b.X(s,new A.hk(b8)))return"Error: linsolve has no solutions"
b5=a.length
o=b8.length
if(b5!==o)return"Error: linsolve has no unique solution"
b0=A.aA(o,$.J(),!1,b6)
for(b1=0;b1<a.length;++b1){b5=a[b1]
if(!(b1<s.length))return A.a(s,b1)
B.b.u(b0,b5,B.b.gR(s[b1]))}b2=b8.length
b3=J.bg(b2,t.N)
for(b1=0;b1<b2;++b1){if(!(b1<b8.length))return A.a(b8,b1)
b5=b8[b1]
if(!(b1<o))return A.a(b0,b1)
b3[b1]=b5+" = "+b0[b1].k(0)}return B.b.H(b3,", ")},
hh:function hh(){},
hi:function hi(a){this.a=a},
hj:function hj(){},
hk:function hk(a){this.a=a},
hg:function hg(){},
pi(a,b){var s,r,q,p,o,n,m,l="Matrix(",k=B.a.p(a)
if(!B.a.J(k,l))return null
for(s=B.a0.gC(B.a0),r=k.length-1;s.q();){q=s.gD()
if(B.a.v(k,q+"(")&&B.a.T(k,")")){p=B.a.p(B.a.F(k,q.length+1,r))
if(B.a.v(p,l)&&B.a.T(p,")"))return A.p7(q,p,b)}}o=A.pf(k)
if(o!=null)return A.mu(o.a,o.b,o.c,b)
n=A.pe(k)
if(n!=null)return A.mu(n.a,n.b,n.c,b)
if(B.a.v(k,l)&&B.a.T(k,")")){m=A.hq(k,b)
if(m!=null)return A.bA(m)}return null},
pf(a){var s,r,q
if(!B.a.J(a,"^"))return null
s=B.a.ec(a,"^")
r=B.a.p(B.a.F(a,0,s))
q=B.a.p(B.a.M(a,s+1))
if(B.a.v(r,"Matrix(")&&B.a.T(r,")"))return new A.f4(r,"^",q)
return null},
pe(a){var s,r,q,p,o,n
for(s=a.length,r=0,q=0;q<s;++q){p=a[q]
if(p==="("||p==="[")++r
if(p===")"||p==="]")--r
if(r!==0)continue
if(q===0)continue
if(p==="+"||p==="-"||p==="*"){o=B.a.p(B.a.F(a,0,q))
n=B.a.p(B.a.M(a,q+1))
if(B.a.v(o,"Matrix(")&&B.a.T(o,")")&&B.a.v(n,"Matrix(")&&B.a.T(n,")"))return new A.f4(o,p,n)}}return null},
hq(a,b){var s,r,q,p,o,n,m,l,k,j,i=null
if(!(B.a.v(a,"Matrix(")&&B.a.T(a,")")))return i
s=A.lc(B.a.p(B.a.F(a,7,a.length-1)))
if(s==null||J.S(s)===0)return i
r=J.oC(s).length
if(J.ek(s,new A.hr(r)))return i
q=b.bl(J.S(s),r)
if(q==null)return i
try{p=0
for(;;){n=p
m=J.S(s)
if(typeof n!=="number")return n.af()
if(!(n<m))break
o=0
for(;;){n=o
m=r
if(typeof n!=="number")return n.af()
if(typeof m!=="number")return A.aU(m)
if(!(n<m))break
n=p
m=o
l=B.a.p(B.b.m(J.aL(s,p),o))
k=A.aX(l)
l=k==null?l:k
q.b8(n,m,l)
n=o
if(typeof n!=="number")return n.A()
o=n+1}n=p
if(typeof n!=="number")return n.A()
p=n+1}}catch(j){return i}return q},
lc(a){var s,r,q,p,o,n,m,l,k,j
if(!B.a.v(a,"[")||!B.a.T(a,"]"))return null
s=B.a.p(B.a.F(a,1,a.length-1))
r=A.d([],t.bj)
for(q=s.length,p=q-1,o=0,n=0,m=0;m<q;++m){l=s[m]
if(l==="["||l==="(")++o
if(l==="]"||l===")")--o
k=m===p
if(l===","&&o===0||k){j=B.a.p(B.a.F(s,n,k?m+1:m))
if(B.a.v(j,"[")&&B.a.T(j,"]"))B.b.l(r,A.pb(j))
else if(j.length!==0)return null
n=m+1}}return r.length===0?null:r},
pb(a){var s,r,q,p,o,n,m,l,k=A.d([],t.s),j=B.a.F(a,1,a.length-1)
for(s=j.length,r=s-1,q=0,p=0,o=0;o<s;++o){n=j[o]
if(n==="("||n==="[")++q
if(n===")"||n==="]")--q
m=o===r
if(n===","&&q===0||m){l=B.a.p(B.a.F(j,p,m?o+1:o))
if(l.length!==0)B.b.l(k,l)
p=o+1}}return k},
mw(a){var s,r,q=a.length
if(q<=8192)s=!(B.a.v(a,"Matrix(")&&B.a.T(a,")"))
else s=!0
if(s)return!1
r=A.lc(B.a.p(B.a.F(a,7,q-1)))
if(r==null||r.length===0||B.b.gP(r).length===0||B.b.X(r,new A.hs(r))||B.b.aA(r,0,new A.ht(),t.p)>64)return!1
q=A.H(r)
return new A.c7(r,q.h("m<i>(1)").a(new A.hu()),q.h("c7<1,i>")).az(0,new A.hv())},
pc(a){var s,r=A.l("^[+-]?\\d+(?:/\\d+)?$",!0),q=B.a.p(a)
if(r.b.test(q))return!0
if(!(B.a.v(a,"Matrix(")&&B.a.T(a,")")))return!1
s=A.lc(B.a.p(B.a.F(a,7,a.length-1)))
q=!1
if(s!=null)if(s.length!==0){q=A.H(s)
q=new A.c7(s,q.h("m<i>(1)").a(new A.hw()),q.h("c7<1,i>")).az(0,new A.hx(r))}return q},
p7(a,b,c){var s,r,q,p,o,n,m=A.hq(b,c)
if(m==null)return"Error: "+a+" invalid matrix literal"
try{if(a==="inv"){if(m.b!==m.c)return"Error: inv failed: Matrix inversion failed: matrix must be square"
if(A.mw(b)&&A.aX(m.bU())==="0")return"Error: inv failed: Matrix inversion failed: singular matrix"}s=null
r=a
A:{if("det"===r){s=m.bU()
break A}if("inv"===r){s=A.bA(m.aS())
break A}if("trace"===r){s=A.pg(m,c)
break A}if("transpose"===r){s=A.bA(A.ph(m,c))
break A}if("rref"===r){s=A.bA(A.pd(m,c))
break A}if("eigenvalues"===r||"eigenvectors"===r){s=A.p8(a,m,c)
break A}s="Error: "+a+" not implemented"
break A}q=s
if(a!=="eigenvalues"&&a!=="eigenvectors"&&A.mw(b)&&A.pc(q))c.a=B.w
return q}catch(n){p=A.ac(n)
o=A.r(p)
if(J.aV(o,"[object Object]")||J.aV(o,"JSObject")||J.aV(o,"JSAny")){s=a==="inv"?"Error: inv failed: Matrix inversion failed":"Error: "+a+" failed"
return s}return"Error: "+a+" failed: "+A.r(p)}},
pg(a,b){var s,r,q,p,o,n=a.b
if(n!==a.c)return"Error: trace requires a square matrix"
if(n===0)return"0"
s=a.cL(0,0)
for(r=v.G,q=a.a,p=1;p<n;++p){o=A.I(r._symCcallStrGetElem(q,p,p))
if(B.a.v(o,"Error"))A.x(A.ap("matrix_get",o,null))
s=s+" + "+o}return b.K(s)},
mu(a,b,c,d){var s,r,q,p,o,n,m="Error: invalid matrix literal",l=A.hq(a,d)
if(b==="^"){if(l==null)return m
o=A.A(c,"(","")
s=A.bk(B.a.p(A.A(o,")","")),null)
if(s==null)return"Error: matrix power must be an integer"
try{if(s===-1){o=A.bA(l.aS())
return o}if(s===2){o=A.bA(l.i(0,l))
return o}if(s===3){o=A.bA(l.i(0,l).i(0,l))
return o}return"Error: unsupported matrix power "+A.r(s)}catch(n){r=A.ac(n)
o=A.r(r)
return"Error: matrix ^ failed: "+o}}q=A.hq(c,d)
if(l==null||q==null)return m
try{switch(b){case"+":o=A.bA(l.A(0,q))
return o
case"-":o=A.bA(l.A(0,A.pa(q,d)))
return o
case"*":o=A.bA(l.i(0,q))
return o}}catch(n){p=A.ac(n)
o=A.r(p)
return"Error: matrix "+b+" failed: "+o}return"Error: unsupported matrix op "+b},
bA(a){var s,r,q,p,o,n,m,l,k=t.s,j=A.d([],k)
for(s=a.b,r=a.c,q=v.G,p=a.a,o=0;o<s;++o){n=A.d([],k)
for(m=0;m<r;++m){l=A.I(q._symCcallStrGetElem(p,o,m))
if(B.a.v(l,"Error"))A.x(A.ap("matrix_get",l,null))
B.b.l(n,l)}B.b.l(j,"["+B.b.H(n,", ")+"]")}return"Matrix(["+B.b.H(j,", ")+"])"},
pa(a,b){var s,r,q,p,o,n=a.b,m=a.c,l=b.bl(n,m)
if(l==null)throw A.c(A.ck("matrix negate: failed to allocate result"))
for(s=v.G,r=a.a,q=0;q<n;++q)for(p=0;p<m;++p){o=A.I(s._symCcallStrGetElem(r,q,p))
if(B.a.v(o,"Error"))A.x(A.ap("matrix_get",o,null))
l.b8(q,p,"-("+o+")")}return l},
ph(a,b){var s,r,q,p,o,n=a.c,m=a.b,l=b.bl(n,m)
if(l==null)throw A.c(A.ck("matrix transpose: failed to allocate result"))
for(s=v.G,r=a.a,q=0;q<m;++q)for(p=0;p<n;++p){o=A.I(s._symCcallStrGetElem(r,q,p))
if(B.a.v(o,"Error"))A.x(A.ap("matrix_get",o,null))
l.b8(p,q,o)}return l},
pd(a0,a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=a0.b,b=a0.c,a=J.bg(c,t.a)
for(s=v.G,r=a0.a,q=t.s,p=0;p<c;++p){o=A.d(new Array(b),q)
for(n=0;n<b;++n){m=A.I(s._symCcallStrGetElem(r,p,n))
if(B.a.v(m,"Error"))A.x(A.ap("matrix_get",m,null))
o[n]=m}a[p]=o}l=0
k=0
for(;;){if(!(k<b&&l<c))break
A:{p=l
for(;;){if(!(p<c)){j=-1
break}if(!(p<a.length))return A.a(a,p)
s=a[p]
if(!(k<s.length))return A.a(s,k)
if(!A.mv(s[k],a1)){j=p
break}++p}if(j===-1)break A
if(j!==l){s=a.length
if(!(l<s))return A.a(a,l)
i=a[l]
if(!(j>=0&&j<s))return A.a(a,j)
a[l]=a[j]
a[j]=i}if(!(l<a.length))return A.a(a,l)
s=a[l]
if(!(k<s.length))return A.a(s,k)
h=s[k]
if(!A.p9(h,a1))for(n=0;n<b;++n){if(!(n<s.length))return A.a(s,n)
B.b.u(s,n,A.hy("("+s[n]+")/("+h+")",a1))}for(p=0;p<c;++p){if(p===l)continue
s=a.length
if(!(p<s))return A.a(a,p)
q=a[p]
if(!(k<q.length))return A.a(q,k)
g=q[k]
if(A.mv(g,a1))continue
for(n=0;n<b;++n){if(!(p<s))return A.a(a,p)
if(!(n<q.length))return A.a(q,n)
f=q[n]
if(!(l<s))return A.a(a,l)
e=a[l]
if(!(n<e.length))return A.a(e,n)
B.b.u(q,n,A.hy("("+f+") - ("+g+")*("+e[n]+")",a1))}}++l}++k}d=a1.bl(c,b)
if(d==null)throw A.c(A.ck("matrix rref: failed to allocate result"))
for(p=0;p<c;++p)for(n=0;n<b;++n){if(!(p<a.length))return A.a(a,p)
s=a[p]
if(!(n<s.length))return A.a(s,n)
d.b8(p,n,s[n])}return d},
hy(a,b){var s=b.a6(a)
if(B.a.v(s,"Error"))return a
return s},
mv(a,b){var s,r=B.a.p(A.hy(a,b))
if(r==="0"||r==="0.0"||r==="-0")return!0
s=A.am(r)
return s!=null&&s===0},
p9(a,b){var s,r=B.a.p(A.hy(a,b))
if(r==="1"||r==="1.0")return!0
s=A.am(r)
return s!=null&&s===1},
p8(a,b,c){var s,r,q,p,o,n,m,l,k,j,i=b.b,h=b.c
if(i!==h)return"Error: eigenvalues require a square matrix"
s=A.d([],t.gy)
for(r=v.G,q=b.a,p=t.n,o=0;o<i;++o){n=A.d([],p)
for(m=0;m<h;++m){l=A.I(r._symCcallStrGetElem(q,o,m))
if(B.a.v(l,"Error"))A.x(A.ap("matrix_get",l,null))
k=A.au(l)
if(k==null)j=null
else j=k.K(B.u)
if(j==null||!isFinite(j))return"Error: "+a+' requires numeric entries (got "'+l+'")'
B.b.l(n,j)}B.b.l(s,n)}l=A.ta(s)
if(l==null)return"Error: invalid matrix for "+a
if(a==="eigenvalues")return l.bL()
else{if(l.b==null)return"Eigenvalues: "+l.bL()+"\nEigenvectors not available for complex eigenvalues"
return"Eigenvalues: "+l.bL()+"\nEigenvectors: "+l.e3()}},
hr:function hr(a){this.a=a},
hs:function hs(a){this.a=a},
ht:function ht(){},
hu:function hu(){},
hv:function hv(){},
hw:function hw(){},
hx:function hx(a){this.a=a},
f4:function f4(a,b,c){this.a=a
this.b=b
this.c=c},
lh(a){var s,r
try{s=A.nd(a).cA(!1)
return s}catch(r){return null}},
cc(a,b){var s=new A.aC(a,A.X(t.N,t.G))
s.b9(a,b)
return s},
mC(a){var s
if(a.length===0)s=A.d([],t.t)
else{s=t.x
s=A.L(new A.t(A.d(a.split(","),t.s),t.v.a(A.cx()),s),s.h("D.E"))}return s},
pv(a){var s,r,q,p,o,n,m,l=null,k=A.po(a)
if(k==null)return l
s=k.b.a
if(s===0)return"0"
if(s===1)return l
r=k.a
if(r.length<2)return l
q=A.le(k)
p=q.a
o=q.b
s=A.pr(o)
if(s==null)s=A.pu(o)
n=s==null?A.pt(o):s
if(n==null)n=A.ps(o)
if(n!=null)return A.lf(p,n,r)
if(r.length===2){m=A.pn(o)
if(m!=null)return A.lf(p,m,r)}if(p!=null)return A.lf(p,A.d([o],t.Y),r)
return l},
le(a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=null
if(a5.b.a<=1)return new A.R(a4,a5)
s=a5.a
r=s.length
q=t.p
p=A.aA(r,999999,!1,q)
for(o=a5.gae(),n=o.$ti,o=new A.af(o.a(),n.h("af<1>")),n=n.c,m=a4;o.q();){l=o.b
if(l==null)l=n.a(l)
k=l.a
j=l.b
for(l=J.aj(k),i=0;i<r;++i)if(l.m(k,i)<p[i])B.b.u(p,i,l.m(k,i))
l=j.a
if(m==null){if(l.a)l=l.n(0)
m=new A.f(l,j.b)}else{if(l.a)l=l.n(0)
h=j.b
g=m.a.aC(0,l)
l=m.b
f=l.i(0,h)
if(f.a)f=f.n(0)
h=l.aC(0,h)
if(h.c===0)A.x(B.e)
m=A.k(g,f.a2(h))}}e=B.b.X(p,new A.hz())
d=m!=null&&!m.I(0,$.u())
if(!e&&!d)return new A.R(a4,a5)
c=d?m:$.u()
b=e?p:A.aA(r,0,!1,q)
if(c.I(0,$.u())&&B.b.az(b,new A.hA()))return new A.R(a4,a5)
q=t.L
o=t.G
a=A.cc(s,A.B([b,c],q,o))
a0=A.X(q,o)
for(q=a5.gae(),o=q.$ti,q=new A.af(q.a(),o.h("af<1>")),n=c.b,l=c.a,h=b.length,f=t.t,o=o.c;q.q();){a1=q.b
if(a1==null)a1=o.a(a1)
k=a1.a
j=a1.b
a2=A.d(new Array(r),f)
for(a1=J.aj(k),i=0;i<r;++i){a3=a1.m(k,i)
if(!(i<h))return A.a(b,i)
a2[i]=a3-b[i]}a0.u(0,a2,A.k(j.a.i(0,n),j.b.i(0,l)))}return new A.R(a,A.cc(s,a0))},
pr(a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=null
if(a2.b.a!==2)return a1
s=a2.gae()
r=A.L(s,s.$ti.h("m.E"))
s=r.length
if(0>=s)return A.a(r,0)
q=r[0]
p=q.a
o=q.b
if(1>=s)return A.a(r,1)
n=r[1]
m=n.a
l=n.b
s=o.a
if(s.gE(0)>0&&l.a.gE(0)<0){k=new A.f(l.a.n(0),l.b)
j=m
i=p
h=o}else{if(l.a.gE(0)>0&&s.gE(0)<0)k=new A.f(s.n(0),o.b)
else return a1
j=p
i=m
h=l}s=J.ar(i)
if(s.X(i,new A.hF())||J.ek(j,new A.hG()))return a1
g=A.hE(h)
f=A.hE(k)
if(g==null||f==null)return a1
e=a2.a
d=t.p
s=s.ap(i,new A.hH(),d)
c=A.L(s,s.$ti.h("D.E"))
s=J.d7(j,new A.hI(),d)
b=A.L(s,s.$ti.h("D.E"))
s=t.L
d=t.G
a=A.cc(e,A.B([c,g,b,f],s,d))
a0=A.cc(e,A.B([c,g,b,new A.f(f.a.n(0),f.b)],s,d))
if(a.i(0,a0).I(0,a2))return A.d([a,a0],t.Y)
return a1},
pu(a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=null
if(a3.b.a!==2)return a2
s=a3.gae()
r=A.L(s,s.$ti.h("m.E"))
s=r.length
if(0>=s)return A.a(r,0)
q=r[0]
p=q.a
o=q.b
if(1>=s)return A.a(r,1)
n=r[1]
m=n.a
l=n.b
s=J.ar(p)
if(s.X(p,new A.hO())||J.ek(m,new A.hP()))return a2
k=o.a
j=k.a?k.n(0):k
i=A.mB(new A.f(j,o.b))
j=l.a
h=j.a?j.n(0):j
g=A.mB(new A.f(h,l.b))
if(i==null||g==null)return a2
f=a3.a
h=t.p
s=s.ap(p,new A.hQ(),h)
e=A.L(s,s.$ti.h("D.E"))
s=J.d7(m,new A.hR(),h)
d=A.L(s,s.$ti.h("D.E"))
c=k.gE(0)===j.gE(0)
s=t.L
h=t.G
b=A.cc(f,A.B([e,i],s,h))
a=A.cc(f,A.B([d,g],s,h))
if(c&&k.gE(0)>0){a0=b.A(0,a)
a1=b.i(0,b).G(0,b.i(0,a)).A(0,a.i(0,a))}else if(c&&k.gE(0)<0)return a2
else if(k.gE(0)>0&&j.gE(0)<0){a0=b.G(0,a)
a1=b.i(0,b).A(0,b.i(0,a)).A(0,a.i(0,a))}else{a0=a.G(0,b)
a1=a.i(0,a).A(0,b.i(0,a)).A(0,b.i(0,b))}if(a0.i(0,a1).I(0,a3))return A.d([a0,a1],t.Y)
return a2},
pt(c1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0
if(c1.b.a!==3)return null
s=c1.gae()
r=A.L(s,s.$ti.h("m.E"))
for(s=t.L,q=t.G,p=t.N,o=t.p,n=t.t,m=c1.a,l=0;l<3;l=k)for(k=l+1,j=3-l,i=k;i<3;++i){h=j-i
g=r.length
if(!(l<g))return A.a(r,l)
f=r[l]
e=f.a
d=f.b
if(!(i<g))return A.a(r,i)
c=r[i]
b=c.a
a=c.b
if(!(h>=0&&h<g))return A.a(r,h)
a0=r[h]
a1=a0.a
a2=a0.b
if(d.a.gE(0)<=0||a.a.gE(0)<=0)continue
g=J.ar(e)
if(g.X(e,new A.hK())||J.ek(b,new A.hL()))continue
a3=A.hE(d)
a4=A.hE(a)
if(a3==null||a4==null)continue
a5=m.length
a6=A.d(new Array(a5),n)
for(a7=J.aj(b),a8=0;a8<a5;++a8)a6[a8]=B.c.S(g.m(e,a8)+a7.m(b,a8),2)
a8=0
for(;;){if(!(a8<m.length)){a9=!0
break}if((g.m(e,a8)+a7.m(b,a8)&1)===1){a9=!1
break}++a8}if(!a9)continue
b1=J.aj(a1)
a8=0
for(;;){if(!(a8<m.length)){b0=!0
break}b2=b1.m(a1,a8)
if(!(a8<a6.length))return A.a(a6,a8)
if(b2!==a6[a8]){b0=!1
break}++a8}if(!b0)continue
b1=a3.a
b2=a4.a
b1=b1.i(0,b2)
b3=a3.b
b4=a4.b
b3=A.k(b1,b3.i(0,b4))
b1=A.C(2)
b5=$.o()
b6=A.k(b3.a.i(0,b1),b3.b.i(0,b5))
b1=!1
b3=b6.a.j(0,a2.a)
if(b3===0)b1=b6.b.j(0,a2.b)===0
if(!b1){b1=b6.a.n(0)
b3=!1
b1=b1.j(0,a2.a)
if(b1===0)b1=b6.b.j(0,a2.b)===0
else b1=b3
b1=!b1}else b1=!1
if(b1)continue
g=g.ap(e,new A.hM(),o)
b7=A.L(g,g.$ti.h("D.E"))
g=a7.ap(b,new A.hN(),o)
b8=A.L(g,g.$ti.h("D.E"))
if(a2.a.gE(0)>0)b9=$.u()
else{g=$.u()
b9=new A.f(g.a.n(0),g.b)}c0=new A.aC(m,A.X(p,q))
c0.b9(m,A.B([b7,a3,b8,A.k(b2.i(0,b9.a),b4.i(0,b9.b))],s,q))
if(c0.i(0,c0).I(0,c1))return A.d([c0,c0],t.Y)}return null},
ps(b0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9=b0.b.a
if(a9<4||a9>6)return null
a9=b0.gae()
s=A.L(a9,a9.$ti.h("m.E"))
r=b0.a
q=s.length
p=q/2|0
if(q!==p*2)return null
o=J.bg(q,t.p)
for(n=0;n<q;++n)o[n]=n
for(a9=A.ld(o,p),m=a9.$ti,a9=new A.af(a9.a(),m.h("af<1>")),l=t.N,k=t.G,j=t.L,i=A.H(o),h=i.h("w(1)"),i=i.h("cn<1>"),g=i.h("m.E"),m=m.c;a9.q();){f=a9.b
if(f==null)f=m.a(f)
e=A.L(new A.cn(o,h.a(new A.hJ(f)),i),g)
d=A.X(j,k)
for(f=J.bu(f);f.q();){c=f.gD()
if(c>>>0!==c||c>=s.length)return A.a(s,c)
c=s[c]
d.u(0,c.a,c.b)}b=A.X(j,k)
for(f=e.length,a=0;a<e.length;e.length===f||(0,A.M)(e),++a){n=e[a]
if(!(n>=0&&n<s.length))return A.a(s,n)
c=s[n]
b.u(0,c.a,c.b)}a0=new A.aC(r,A.X(l,k))
a0.b9(r,d)
a1=new A.aC(r,A.X(l,k))
a1.b9(r,b)
a2=A.le(a0)
a3=a2.a
a4=a2.b
a5=A.le(a1)
a6=a5.a
a7=a5.b
if(a3==null||a6==null)continue
if(a4.b.a===0||a7.b.a===0)continue
if(a4.I(0,a7)){a8=a3.A(0,a6)
if(a8.b.a===0)continue
if(a8.i(0,a4).I(0,b0))return A.d([a8,a4],t.Y)}if(a4.I(0,a7.a_(new A.f(A.C(-1),$.o())))){a8=a3.G(0,a6)
if(a8.b.a===0)continue
if(a8.i(0,a4).I(0,b0))return A.d([a8,a4],t.Y)}}return null},
pn(a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=null,a4=a5.a
if(a4.length!==2)return a3
s=a5.dW(0)+1
r=t.p
q=t.G
p=A.X(r,q)
for(o=a5.gae(),n=o.$ti,o=new A.af(o.a(),n.h("af<1>")),n=n.c;o.q();){m=o.b
if(m==null)m=n.a(m)
l=m.a
k=m.b
m=J.aj(l)
j=m.m(l,0)+m.m(l,1)*s
m=p.m(0,j)
if(m==null)m=$.J()
i=k.b
h=m.b
p.u(0,j,A.k(m.a.i(0,i).A(0,k.a.i(0,h)),h.i(0,i)))}g=new A.at(p,p.$ti.h("at<1>")).aA(0,0,new A.hC(),r)
if(g>200)return a3
f=g+1
e=J.bg(f,q)
for(d=0;d<f;++d){r=p.m(0,d)
e[d]=r==null?$.J():r}c=A.bj(e,"x")
if(c.a.length===0)return a3
b=A.pl(c)
if(b==null||b.length<=1)return a3
a=A.d([],t.Y)
for(r=b.length,a0=0;a0<b.length;b.length===r||(0,A.M)(b),++a0){a1=A.pq(b[a0],a4,s)
B.b.l(a,a1)}if(0>=a.length)return A.a(a,0)
a2=a[0]
for(d=1;d<a.length;++d)a2=a2.i(0,a[d])
if(a2.I(0,a5))return a
return a3},
pq(a,b,c){var s,r,q,p,o,n,m=A.X(t.L,t.G)
for(s=a.a,r=s.length-1,q=t.t,p=0;p<=r;++p){o=s[p].a.j(0,$.p())
if(o===0)continue
n=B.c.au(p,c)
m.u(0,A.d([B.c.W(p,c),n],q),s[p])}return A.cc(b,m)},
pl(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null
if(a.a.length-1<=1)return d
s=A.d([],t.k)
r=a.aT()
q=a.b
p=a.gb_()
o=A.pp(r)
if(o==null)return d
for(n=A.f9(o,o.r,A.q(o).c),m=t.G,l=n.$ti.c;n.q();){k=n.d
if(k==null)k=l.a(k)
j=k.a
for(;;){if(r.a.length-1>=1)i=A.pk(r,k).a.j(0,$.p())===0
else i=!1
if(!i)break
h=A.bh([$.J(),$.u()],!1,m)
h.$flags=3
i=j.j(0,$.p())
if(i===0)i=new A.G(B.h,q)
else{g=A.bh([k],!1,m)
g.$flags=3
i=new A.G(g,q)}f=new A.G(h,q).G(0,i)
e=r.Y(f)
if(e.b.a.length!==0)break
r=e.a
B.b.l(s,f)}}if(r.a.length-1>=1)B.b.l(s,r)
if(s.length<=1&&p.I(0,$.u()))return d
if(s.length===0)return d
if(!p.I(0,$.u())){if(0>=s.length)return A.a(s,0)
B.b.u(s,0,s[0].a_(p))}return s.length>1?s:d},
pk(a,b){var s,r,q,p,o,n,m,l,k=$.J()
for(s=a.a,r=s.length-1,q=b.a,p=b.b;r>=0;--r){o=A.k(k.a.i(0,q),k.b.i(0,p))
n=s[r]
m=n.b
l=o.b
k=A.k(o.a.i(0,m).A(0,n.a.i(0,l)),l.i(0,m))}return k},
pp(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=A.pm(a),e=B.b.gR(f)
if(e.a)e=e.n(0)
s=B.b.bn(f,new A.hD())
if(s<0)return null
if(!(s<f.length))return A.a(f,s)
r=f[s]
q=A.mx(r.a?r.n(0):r)
p=A.mx(e)
if(q==null||p==null)return null
o=A.cK(t.G)
if(s>0)o.l(0,$.J())
for(n=A.f9(q,q.r,A.q(q).c),m=A.q(p),l=m.h("ba<1>"),m=m.c,k=n.$ti.c;n.q();){j=n.d
if(j==null)j=k.a(j)
for(i=new A.ba(p,p.r,l),i.c=p.e;i.q();){h=i.d
g=A.k(j,h==null?m.a(h):h)
o.l(0,g)
o.l(0,new A.f(g.a.n(0),g.b))}}return o},
pm(a){var s,r,q,p,o,n,m=$.o()
for(s=a.a,r=s.length,q=0;q<r;++q){p=s[q].b
o=m.i(0,p)
if(o.a)o=o.n(0)
p=m.aC(0,p)
if(p.c===0)A.x(B.e)
m=o.a2(p)}p=A.d([],t.W)
for(q=0;q<r;++q){n=s[q]
o=n.b
if(o.c===0)A.x(B.e)
p.push(n.a.i(0,m.a2(o)))}return p},
mx(a){var s,r,q,p,o=$.p()
if(a.j(0,o)<=0)return A.ms([$.o()],t.Z)
if(a.j(0,A.C(1e12))>0)return null
s=A.cK(t.Z)
r=$.o()
for(q=r;q.i(0,q).j(0,a)<=0;){p=a.W(0,q).j(0,o)
if(p===0){s.l(0,q)
if(q.c===0)A.x(B.e)
s.l(0,a.a2(q))}q=q.A(0,r)}return s},
lf(a,b,c){var s,r,q,p=A.d([],t.s)
if(a!=null&&!A.mA(a))B.b.l(p,A.my(a))
for(s=b.length,r=0;r<b.length;b.length===s||(0,A.M)(b),++r){q=b[r]
if(A.mA(q))continue
B.b.l(p,A.my(q))}if(p.length===0)return"1"
return B.b.H(p,"*")},
mA(a){var s,r,q,p,o,n,m
if(a.b.a!==1)return!1
for(s=a.gae(),r=s.$ti,s=new A.af(s.a(),r.h("af<1>")),r=r.c;s.q();){q=s.b
if(q==null)q=r.a(q)
p=q.a
o=q.b
if(J.ek(p,new A.hB()))return!1
q=$.u()
n=!1
m=q.a.j(0,o.a)
if(m===0)q=q.b.j(0,o.b)===0
else q=n
if(!q)return!1}return!0},
my(a){var s=a.k(0)
if(a.b.a>1)return"("+s+")"
return s},
po(a){var s,r
try{s=A.nd(a).aN()
return s}catch(r){return null}},
hE(a){var s,r=A.mz(a.a)
if(r==null)return null
s=A.mz(a.b)
if(s==null)return null
return A.k(r,s)},
mz(a){var s,r,q,p,o=$.p()
if(a.j(0,o)<0)return null
s=a.j(0,o)
if(s===0)return o
o=$.o()
s=a.j(0,o)
if(s===0)return o
r=a.A(0,o).ak(0,1)
for(q=a;r.j(0,q)<0;q=r,r=p){if(r.c===0)A.x(B.e)
p=r.A(0,a.a2(r)).ak(0,1)}return q.i(0,q).I(0,a)?q:null},
mB(a){var s,r=A.lg(a.a)
if(r==null)return null
s=A.lg(a.b)
if(s==null)return null
return A.k(r,s)},
lg(a){var s,r,q,p,o,n,m=$.p(),l=a.j(0,m)
if(l===0)return m
l=$.o()
s=a.j(0,l)
if(s===0)return l
if(a.j(0,m)<0){r=A.lg(a.n(0))
return r!=null?r.n(0):null}q=l.aj(0,B.c.S(a.gt(0)+2,3))
for(p=0;p<100;++p,q=n){o=q.i(0,q)
m=$.bO().i(0,q)
if(o.c===0)A.x(B.e)
m=m.A(0,a.a2(o))
l=A.C(3)
if(l.c===0)A.x(B.e)
n=m.a2(l)
if(n.j(0,q)>=0)break}if(q.i(0,q).i(0,q).I(0,a))return q
q=q.A(0,$.o())
if(q.i(0,q).i(0,q).I(0,a))return q
return null},
ld(a,b){return new A.br(A.pj(a,b),t.aM)},
pj(a,b){return function(){var s=a,r=b
var q=0,p=2,o=[],n,m,l,k,j,i,h,g
return function $async$ld(c,d,e){if(d===1){o.push(e)
q=p}for(;;)switch(q){case 0:q=r===0?3:4
break
case 3:q=5
return c.b=A.d([],t.t),1
case 5:q=1
break
case 4:n=s.length
if(r>n){q=1
break}q=r===n?6:7
break
case 6:q=8
return c.b=A.bh(s,!0,t.p),1
case 8:q=1
break
case 7:n=r-1,m=t.t,l=0
case 9:if(!(l<=s.length-r)){q=11
break}k=l+1,j=A.ld(B.b.cR(s,k),n),i=j.$ti,j=new A.af(j.a(),i.h("af<1>")),i=i.c
case 12:if(!j.q()){q=13
break}h=j.b
if(h==null)h=i.a(h)
if(!(l<s.length)){A.a(s,l)
q=1
break}g=A.d([s[l]],m)
B.b.aJ(g,h)
q=14
return c.b=g,1
case 14:q=12
break
case 13:case 10:l=k
q=9
break
case 11:case 1:return 0
case 2:return c.c=o.at(-1),3}}}},
nd(a){var s=A.A(a,"**","^")
return new A.jJ(A.A(s," ",""),A.cK(t.N))},
lK(a){var s,r,q,p
for(s=new A.aP(a,a.r,a.e,A.q(a).h("aP<1>")),r=0;s.q();){for(q=s.d.gaU(),q=q.gC(q),p=0;q.q();)p+=q.gD()
if(p>r)r=p}return r},
qS(a){var s,r,q,p,o=A.l("^\\d+$",!0)
if(o.b.test(a))return A.k(A.ae(a,null),$.o())
s=A.l("^(\\d*)\\.(\\d+)$",!0).a3(a)
if(s!=null){o=s.b
r=o.length
if(1>=r)return A.a(o,1)
q=o[1]
if(q.length===0)p="0"
else{q=q
q.toString
p=q}if(2>=r)return A.a(o,2)
o=o[2]
o.toString
return A.k(A.ae(p+o,null),A.C(10).a1(o.length))}return null},
ne(a){var s
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
return s>=48&&s<=57},
lJ(a){var s,r
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
if(!(s>=65&&s<=90))r=s>=97&&s<=122
else r=!0
return r},
aC:function aC(a,b){this.a=a
this.b=b},
hV:function hV(){},
hU:function hU(){},
hS:function hS(){},
hT:function hT(){},
hz:function hz(){},
hA:function hA(){},
hF:function hF(){},
hG:function hG(){},
hH:function hH(){},
hI:function hI(){},
hO:function hO(){},
hP:function hP(){},
hQ:function hQ(){},
hR:function hR(){},
hK:function hK(){},
hL:function hL(){},
hM:function hM(){},
hN:function hN(){},
hJ:function hJ(a){this.a=a},
hC:function hC(){},
hD:function hD(){},
hB:function hB(){},
jJ:function jJ(a,b){var _=this
_.a=a
_.c=_.b=0
_.d=b},
jL:function jL(){},
jK:function jK(){},
li(a){var s=A.bV(a)
if(s==null||!isFinite(s))return null
return A.pz(s)},
bV(a){var s=A.au(a)
if(s==null)s=null
else s=s.K(B.u)
return s},
au(a){var s,r,q,p,o
if($.ce.a8(a)){r=$.ce.ad(0,a)
$.ce.u(0,a,r)
return r}s=null
try{q=new A.jM(a)
p=q.bB()
q.av()
q=q.b
if(q!==a.length)A.x(A.bZ("trailing input at "+q))
s=new A.es(p)}catch(o){s=null}$.ce.u(0,a,s)
if($.ce.a>128)$.ce.ad(0,new A.at($.ce,A.q($.ce).h("at<1>")).gP(0))
return s},
pz(a){var s,r,q,p,o
if(a===0)return"0"
if(a===B.f.b6(a)&&Math.abs(a)<1e16)return B.f.cG(a,0)
s=B.f.bQ(a,15)
r=B.a.ao(s,"e")
if(r<0)r=B.a.ao(s,"E")
if(r>=0){q=B.a.F(s,0,r)
if(!B.a.J(q,"."))return s
p=A.l("0+$",!0)
p=A.A(q,p,"")
o=A.l("\\.$",!0)
return A.A(p,o,"")+B.a.M(s,r)}if(B.a.J(s,".")){p=A.l("0+$",!0)
p=A.A(s,p,"")
o=A.l("\\.$",!0)
s=A.A(p,o,"")}return s},
bZ(a){return new A.jr(a)},
nG(a){var s,r,q
A.bs(a)
if(a<0.5)return 3.141592653589793/(Math.sin(3.141592653589793*a)*A.nG(1-a));--a
s=a+7+0.5
for(r=0.9999999999998099,q=1;q<9;++q)r+=B.hD[q]/(a+q)
return Math.sqrt(6.283185307179586)*Math.pow(s,a+0.5)*Math.exp(-s)*r},
lL(a){var s
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
return s>=48&&s<=57},
nf(a){var s,r
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
if(!(s>=65&&s<=90))r=s>=97&&s<=122||a==="_"
else r=!0
return r},
jr:function jr(a){this.a=a},
ke:function ke(){},
kf:function kf(){},
kg:function kg(){},
kn:function kn(){},
ko:function ko(){},
kp:function kp(){},
kq:function kq(){},
kr:function kr(){},
ks:function ks(){},
kt:function kt(){},
ku:function ku(){},
kh:function kh(){},
ki:function ki(){},
kj:function kj(){},
kk:function kk(){},
kl:function kl(){},
km:function km(){},
es:function es(a){this.a=a},
jM:function jM(a){this.a=a
this.b=0},
jN:function jN(a,b){this.a=a
this.b=b},
jO:function jO(a,b){this.a=a
this.b=b},
jU:function jU(a,b){this.a=a
this.b=b},
jV:function jV(a,b){this.a=a
this.b=b},
jW:function jW(a,b){this.a=a
this.b=b},
jX:function jX(a,b){this.a=a
this.b=b},
jY:function jY(a){this.a=a},
jT:function jT(a,b){this.a=a
this.b=b},
jS:function jS(a){this.a=a},
jP:function jP(a,b){this.a=a
this.b=b},
jQ:function jQ(a){this.a=a},
jR:function jR(a){this.a=a},
pC(a,b,c,d,e){var s,r,q,p,o,n,m,l,k=A.d([],t.q),j=(d-e)/c,i=A.A(a," ",""),h=A.au(A.A(i,"**","^"))
i=A.A(b," ","")
s=A.au(A.A(i,"**","^"))
for(i=t.N,r=t.V,q=s==null,p=h==null,o=0;o<=c;++o){n=e+o*j
m=p?null:h.K(A.B(["t",n],i,r))
l=q?null:s.K(A.B(["t",n],i,r))
if(m==null||l==null||!isFinite(m)||!isFinite(l))B.b.l(k,new A.aR(!1,0,0))
else B.b.l(k,new A.aR(!0,m,l))}return k},
pD(a,b,c){var s,r,q,p,o,n=A.A(a,"\u03b8","theta"),m=A.d([],t.q),l=c/b,k=A.A(n," ",""),j=A.au(A.A(k,"**","^"))
for(k=t.N,s=t.V,r=j==null,q=0;q<=b;++q){p=0+q*l
o=r?null:j.K(A.B(["theta",p,"t",p],k,s))
if(o==null||!isFinite(o))B.b.l(m,new A.aR(!1,0,0))
else B.b.l(m,new A.aR(!0,o*Math.cos(p),o*Math.sin(p)))}return m},
pB(b1,b2,b3,b4,b5,b6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5=A.A(b1," ",""),a6=A.au(A.A(a5,"**","^")),a7=(b3-b4)/b2,a8=(b5-b6)/b2,a9=b2+1,b0=J.bg(a9,t.H)
for(a5=t.V,s=0;s<a9;++s)b0[s]=A.aA(a9,0/0,!1,a5)
for(r=t.N,q=a6==null,s=0;s<=b2;++s){p=b4+s*a7
for(o=0;o<=b2;++o){n=q?null:a6.K(A.B(["x",p,"y",b6+o*a8],r,a5))
if(!(s<b0.length))return A.a(b0,s)
m=b0[s]
B.b.u(m,o,n!=null&&isFinite(n)?n:0/0)}}l=A.d([],t.B)
for(s=0;s<b2;s=j)for(k=b4+s*a7,j=s+1,i=b4+j*a7,o=0;o<b2;o=g){h=b6+o*a8
g=o+1
f=b6+g*a8
a5=b0.length
if(!(s<a5))return A.a(b0,s)
r=b0[s]
q=r.length
if(!(o<q))return A.a(r,o)
e=r[o]
if(!(j<a5))return A.a(b0,j)
a5=b0[j]
m=a5.length
if(!(o<m))return A.a(a5,o)
d=a5[o]
if(!(g<m))return A.a(a5,g)
c=a5[g]
if(!(g<q))return A.a(r,g)
b=r[g]
if(isNaN(e)||isNaN(d)||isNaN(c)||isNaN(b))continue
a=e>=0?1:0
if(d>=0)a|=2
if(c>=0)a|=4
if(b>=0)a|=8
if(a===0||a===15)continue
a0=new A.i0(k,i,e,d,h)
a1=new A.i2(h,f,d,c,i)
a2=new A.i3(k,i,b,c,f)
a3=new A.i1(h,f,e,b,k)
a4=new A.i_(l)
switch(a){case 1:case 14:a4.$2(a3.$0(),a0.$0())
break
case 2:case 13:a4.$2(a0.$0(),a1.$0())
break
case 3:case 12:a4.$2(a3.$0(),a1.$0())
break
case 4:case 11:a4.$2(a1.$0(),a2.$0())
break
case 5:a4.$2(a3.$0(),a2.$0())
a4.$2(a0.$0(),a1.$0())
break
case 6:case 9:a4.$2(a0.$0(),a2.$0())
break
case 7:case 8:a4.$2(a3.$0(),a2.$0())
break
case 10:a4.$2(a3.$0(),a0.$0())
a4.$2(a1.$0(),a2.$0())
break}}return l},
pE(a8,a9,b0,b1,b2,b3,b4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=(b1-b2)/b0,a5=(b3-b4)/b0,a6=A.A(a8," ",""),a7=A.au(A.A(a6,"**","^"))
a6=A.A(a9," ","")
s=new A.i4(a7)
r=new A.i5(A.au(A.A(a6,"**","^")))
q=A.d([],t.B)
p=A.d([],t.fC)
for(o=0,n=0;n<=b0;++n)for(m=b2+n*a4,l=0;l<=b0;++l){k=b4+l*a5
j=s.$2(m,k)
i=r.$2(m,k)
if(j!=null&&i!=null&&!isNaN(j)&&!isNaN(i)){h=Math.sqrt(j*j+i*i)
if(h>o)o=h
B.b.l(p,new A.e0([h,j,i,m,k]))}}if(o===0)return q
g=Math.min(a4,a5)*0.8
for(a6=p.length,f=0;f<p.length;p.length===a6||(0,A.M)(p),++f){e=p[f].a
d=e[0]
if(d<0.000001)continue
c=d/o*g
b=e[1]/d*c
a=e[2]/d*c
d=e[3]
a0=d+b
e=e[4]
a1=e+a
B.b.l(q,new A.c0([d,a0,e,a1]))
a2=Math.atan2(a,b)
a3=c*0.3
e=a2-0.5
B.b.l(q,new A.c0([a0,a0-a3*Math.cos(e),a1,a1-a3*Math.sin(e)]))
e=a2+0.5
B.b.l(q,new A.c0([a0,a0-a3*Math.cos(e),a1,a1-a3*Math.sin(e)]))}return q},
hZ(a,b,c,d){var s=c-d
if(s===0)return(a+b)/2
return a+(b-a)*(c/s)},
i0:function i0(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
i2:function i2(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
i3:function i3(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
i1:function i1(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
i_:function i_(a){this.a=a},
i4:function i4(a){this.a=a},
i5:function i5(a){this.a=a},
mJ(a,b){return new A.f(a,b)},
k(a,b){var s,r=$.p(),q=b.j(0,r)
if(q===0)throw A.c(A.aG("Rational with zero denominator",null))
if(b.j(0,r)<0){a=a.n(0)
b=b.n(0)}s=a.aC(0,b)
if(s.j(0,$.o())>0){a=a.au(0,s)
b=b.au(0,s)}return new A.f(a,b)},
dw(a,b){var s=a.a.j(0,$.p())
return s===0?new A.G(B.h,b):new A.G(A.cb([a],t.G),b)},
bj(a,b){var s,r=a.length
for(;;){if(r>0){s=r-1
if(!(s<a.length))return A.a(a,s)
s=a[s].a.j(0,$.p())===0}else s=!1
if(!s)break;--r}if(r===0)return new A.G(B.h,b)
return new A.G(A.cb(B.b.bq(a,0,r),t.G),b)},
cM(a,b){var s,r=a.length
for(;;){if(r>0){s=r-1
if(!(s<a.length))return A.a(a,s)
s=a[s].a.j(0,$.p())===0}else s=!1
if(!s)break;--r}return new A.G(A.cb(B.b.bq(a,0,r),t.G),b)},
cf(a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5=null,a6=A.A(a8," ",""),a7=A.A(a6,"**","^")
if(a7.length===0||B.a.J(a7,"(")||B.a.J(a7,")"))return a5
if(!B.a.v(a7,"+")&&!B.a.v(a7,"-"))a7="+"+a7
s=A.l("([+-])([^+-]+)",!0)
r=A.l("[a-zA-Z]",!0)
a6=t.G
q=A.X(t.p,a6)
for(p=s.am(0,a7),p=new A.co(p.a,p.b,p.c),o=t.F,n=a5,m=0;p.q();){l=p.d
k=(l==null?o.a(l):l).b
j=k.index
if(j!==m)return a5
m=j+k[0].length
j=k.length
if(1>=j)return A.a(k,1)
i=k[1]
i.toString
if(2>=j)return A.a(k,2)
k=k[2]
k.toString
j=r.am(0,k)
h=A.L(j,A.q(j).h("m.E"))
j=h.length
if(j===0){g=A.mG(k)
if(g==null)return a5
f=g
e=0}else{if(j!==1)return a5
j=B.b.gP(h).b
if(0>=j.length)return A.a(j,0)
j=j[0]
j.toString
d=n==null
if(!d&&n!==j)return a5
if(d)n=j
c=B.b.gP(h).b.index
b=B.a.F(k,0,c)
if(B.a.T(b,"*"))b=B.a.F(b,0,b.length-1)
if(b.length===0)f=$.u()
else{g=A.mG(b)
if(g==null)return a5
f=g}a=B.a.M(k,c+1)
if(a.length===0)e=1
else{if(!B.a.v(a,"^"))return a5
a0=A.bk(B.a.M(a,1),a5)
if(a0==null||a0<0)return a5
e=a0}}a1=i==="-"?new A.f(f.a.n(0),f.b):f
k=q.m(0,e)
if(k==null)k=$.J()
j=a1.b
i=k.b
q.u(0,e,A.k(k.a.i(0,j).A(0,a1.a.i(0,i)),i.i(0,j)))}if(m!==a7.length||q.a===0)return a5
if(n==null)n="x"
a2=new A.at(q,q.$ti.h("at<1>")).cE(0,new A.ij())+1
a3=J.bg(a2,a6)
for(a4=0;a4<a2;++a4){a6=q.m(0,a4)
a3[a4]=a6==null?$.J():a6}return A.cM(a3,n)},
mG(a){var s,r,q,p,o,n,m=null,l=A.l("^\\d+$",!0)
if(l.b.test(a))return A.k(A.ae(a,m),$.o())
s=A.l("^(\\d+)/(\\d+)$",!0).a3(a)
if(s!=null){l=s.b
if(2>=l.length)return A.a(l,2)
r=l[2]
r.toString
q=A.ae(r,m)
r=q.j(0,$.p())
if(r===0)return m
if(1>=l.length)return A.a(l,1)
l=l[1]
l.toString
return A.k(A.ae(l,m),q)}p=A.l("^(\\d+)\\.(\\d+)$",!0).a3(a)
if(p!=null){l=p.b
r=l.length
if(1>=r)return A.a(l,1)
o=l[1]
if(2>=r)return A.a(l,2)
n=A.ae(A.r(o)+A.r(l[2]),m)
o=A.C(10)
if(2>=l.length)return A.a(l,2)
return A.k(n,o.a1(l[2].length))}return m},
ll(a,b){var s,r,q
for(s=b,r=a;s.a.length!==0;r=s,s=q)q=r.Y(s).b
return r.aT()},
pI(a,b){var s,r,q,p,o,n,m,l=a.a,k=l.length-1,j=b.a,i=j.length-1
if(k<0||i<0)return $.J()
s=k+i
if(s===0)return $.u()
r=t.j
q=A.d([],r)
for(p=k;p>=0;--p)q.push(l[p])
l=A.d([],r)
for(p=i;p>=0;--p)l.push(j[p])
o=J.bg(s,t.bJ)
for(j=t.G,n=0;n<s;++n)o[n]=A.aA(s,$.J(),!1,j)
for(m=0;m<i;++m)for(p=0;p<=k;++p){if(!(m<o.length))return A.a(o,m)
j=o[m]
if(!(p<q.length))return A.a(q,p)
B.b.u(j,m+p,q[p])}for(m=0;m<k;++m)for(j=i+m,p=0;p<=i;++p){if(!(j>=0&&j<o.length))return A.a(o,j)
r=o[j]
if(!(p<l.length))return A.a(l,p)
B.b.u(r,m+p,l[p])}return A.pH(o)},
pH(a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=a2.length
if(a1===0)return $.u()
s=A.d([],t.eu)
for(r=a2.length,q=t.G,p=0;p<a2.length;a2.length===r||(0,A.M)(a2),++p)s.push(A.bh(a2[p],!0,q))
o=$.u()
for(n=0;n<a1;n=l){l=n
for(;;){if(!(l<a1)){m=-1
break}if(!(l<s.length))return A.a(s,l)
r=s[l]
if(!(n<r.length))return A.a(r,n)
r=r[n].a.j(0,$.p())
if(r!==0){m=l
break}++l}if(m===-1)return $.J()
if(m!==n){r=s.length
if(!(m>=0&&m<r))return A.a(s,m)
k=s[m]
if(!(n<r))return A.a(s,n)
s[m]=s[n]
s[n]=k
o=new A.f(o.a.n(0),o.b)}if(!(n<s.length))return A.a(s,n)
r=s[n]
if(!(n<r.length))return A.a(r,n)
r=r[n]
o=A.k(o.a.i(0,r.a),o.b.i(0,r.b))
r=$.u()
if(!(n<s.length))return A.a(s,n)
q=s[n]
if(!(n<q.length))return A.a(q,n)
q=q[n]
j=A.k(r.a.i(0,q.b),r.b.i(0,q.a))
for(l=n+1,r=j.a,q=j.b,i=l;i<a1;++i){if(!(i<s.length))return A.a(s,i)
h=s[i]
if(!(n<h.length))return A.a(h,n)
h=h[n].a.j(0,$.p())
if(h===0)continue
if(!(i<s.length))return A.a(s,i)
h=s[i]
if(!(n<h.length))return A.a(h,n)
h=h[n]
g=A.k(h.a.i(0,r),h.b.i(0,q))
for(h=g.a,f=g.b,e=n;e<a1;++e){d=s.length
if(!(i<d))return A.a(s,i)
c=s[i]
if(!(e<c.length))return A.a(c,e)
b=c[e]
if(!(n<d))return A.a(s,n)
d=s[n]
if(!(e<d.length))return A.a(d,e)
d=d[e]
d=A.k(h.i(0,d.a),f.i(0,d.b))
a=d.b
a0=b.b
B.b.u(c,e,A.k(b.a.i(0,a).G(0,d.a.i(0,a0)),a0.i(0,a)))}}}return o},
f:function f(a,b){this.a=a
this.b=b},
G:function G(a,b){this.a=a
this.b=b},
ij:function ij(){},
ii:function ii(a){this.a=a},
ih:function ih(a,b){this.a=a
this.b=b},
ig:function ig(a,b){this.a=a
this.b=b},
lj(a){var s=a.a
if((s.a?s.n(0):s).gt(0)+a.b.gt(0)>4096)throw A.c(B.l)
return a},
eP(a){var s,r,q,p=a.a,o=p.length
if(o-1>16)throw A.c(B.en)
for(s=0;s<o;++s){r=p[s]
q=r.a
if((q.a?q.n(0):q).gt(0)+r.b.gt(0)>4096)A.x(B.l)}},
mD(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c
A.eP(a)
A.eP(b)
s=b.a
r=s.length
if(r===0)throw A.c(B.ek)
q=a.b
p=r-1
o=a
for(;;){n=o.a
m=n.length
if(!(m!==0&&m-1>=p))break
l=m-1
k=l-p
if(!(l>=0))return A.a(n,l)
l=n[l]
if(!(p>=0))return A.a(s,p)
m=s[p]
j=A.k(l.a.i(0,m.b),l.b.i(0,m.a))
m=j.a
l=j.b
if((m.a?m.n(0):m).gt(0)+l.gt(0)>4096)A.x(B.l)
i=A.d(n.slice(0),A.H(n))
for(h=0;h<=p;++h){n=s[h]
g=A.k(m.i(0,n.a),l.i(0,n.b))
n=g.a
f=g.b
if((n.a?n.n(0):n).gt(0)+f.gt(0)>4096)A.x(B.l)
e=h+k
if(!(e>=0&&e<i.length))return A.a(i,e)
d=i[e]
c=d.b
f=A.k(d.a.i(0,f).G(0,n.i(0,c)),c.i(0,f))
n=f.a
if((n.a?n.n(0):n).gt(0)+f.b.gt(0)>4096)A.x(B.l)
B.b.u(i,e,f)}o=A.bj(i,q)}return o},
mF(a,b){var s,r,q,p,o,n,m,l,k,j
try{p={}
A.eP(a)
A.eP(b)
p.a=a
s=b
for(o=a;s.a.length!==0;o=n){r=A.mD(o,s)
n=s
p.a=n
s=r}m=o.a
if(m.length===0)return o
o=A.H(m)
l=o.h("t<1,f>")
k=A.L(new A.t(m,o.h("f(1)").a(new A.i6(p)),l),l.h("D.E"))
q=k
o=A.bj(q,a.b)
return o}catch(j){if(A.ac(j) instanceof A.T)return null
else throw j}},
lk(a,b){var s,r,q,p,o,n,m,l,k=$.J()
for(s=a.a,r=A.H(s).h("ci<1>"),s=new A.ci(s,r),s=new A.b6(s,s.gB(0),r.h("b6<D.E>")),q=b.a,p=b.b,r=r.h("D.E");s.q();){o=s.d
if(o==null)o=r.a(o)
n=A.k(k.a.i(0,q),k.b.i(0,p))
m=n.a
n=n.b
if((m.a?m.n(0):m).gt(0)+n.gt(0)>4096)A.x(B.l)
l=o.b
k=A.k(m.i(0,l).A(0,o.a.i(0,n)),n.i(0,l))
o=k.a
if((o.a?o.n(0):o).gt(0)+k.b.gt(0)>4096)A.x(B.l)}return k},
mE(a){var s,r,q,p,o=null,n=A.aX(a)
if(n==null)return o
s=n.split("/")
r=s.length
if(0>=r)return A.a(s,0)
q=A.ae(s[0],o)
if(r===1)r=$.o()
else{if(1>=r)return A.a(s,1)
r=A.ae(s[1],o)}p=A.k(q,r)
r=p.a
return(r.a?r.n(0):r).gt(0)+p.b.gt(0)<=4096?p:o},
pF(a,b,c){var s,r,q,p,o,n,m,l,k
try{A.eP(a)
A.lj(b)
A.lj(c)
s=b.G(0,c).a.gE(0)>0
r=s?c:b
q=s?b:c
m=a.a.length
if(m===0)return!0
if(m-1===0)return!1
m=A.lk(a,r)
l=$.p()
m=m.a.j(0,l)
if(m!==0)m=A.lk(a,q).a.j(0,l)===0
else m=!0
if(m)return!0
p=A.d([a,a.ah()],t.k)
while(J.l_(p).a.length!==0){o=A.mD(J.aL(p,J.S(p)-2),J.l_(p)).a_(new A.f(A.C(-1),$.o()))
if(o.a.length===0)break
J.fo(p,o)}n=new A.i7(p)
m=n.$1(r)
l=n.$1(q)
if(typeof m!=="number")return m.cM()
if(typeof l!=="number")return A.aU(l)
return m>l}catch(k){if(A.ac(k) instanceof A.T)return null
else throw k}},
i6:function i6(a){this.a=a},
i7:function i7(a){this.a=a},
pG(c4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3=null
if(c4.length>512)return c3
s=B.a.p(c4)
for(;;){if(!(B.a.v(s,"(")&&B.a.T(s,")")))break
for(r=s.length,q=r-1,p=0,o=!0,n=0;n<r;++n){m=s[n]
if(m==="(")++p
if(m===")")--p
if(p===0&&n<q)o=!1}if(!o||p!==0)break
s=B.a.p(B.a.F(s,1,q))}for(r=s.length,p=0,l=-1,n=0;n<r;++n){q=s[n]
if(q==="(")++p
if(q===")")--p
if(p<0)return c3
if((q==="+"||q==="-")&&p===0&&n>0){k=B.a.bS(B.a.F(s,0,n))
q=k.length
if(q!==0){m=q-1
if(!(m>=0))return A.a(k,m)
m=!B.a.J("+-*/^(",k[m])
q=m}else q=!1
if(q)return c3}if(s[n]==="/"&&p===0){if(l>=0)return c3
l=n}}if(l<0||p!==0)return c3
j=A.lh(B.a.F(s,0,l))
i=B.a.M(s,l+1)
h=A.lh(i)
r=!0
if(j!=null)if(h!=null){r=h.b.a
r=r===0||j.b.a>64||r>64||j.gbR()>16||h.gbR()>16}if(r)return c3
r=A.L(j.gae(),t.bv)
B.b.aJ(r,h.gae())
if(B.b.X(r,new A.i9()))return c3
r=t.N
q=A.hn(j.a,r)
q.aJ(0,h.a)
g=A.L(q,A.q(q).c)
B.b.aV(g)
q=g.length
if(q<2||q>4)return c3
f=new A.i8(g)
e=new A.ic()
d=new A.id(e)
c=f.$1(j)
b=f.$1(h)
a=d.$1(b)
a0=e.$1(a)
a1=A.X(r,t.G)
for(r=t.t,q=J.aj(a0),m=t.f7,a2=0;a3=c.a,a3!==0;++a2){if(a2>=256||a3>128||a1.a>64)return c3
a4=d.$1(c)
a5=e.$1(a4)
a6=g.length
a7=A.d(new Array(a6),m)
for(a3=J.aj(a5),n=0;n<a6;++n)a7[n]=a3.m(a5,n)<q.m(a0,n)
if(B.b.X(a7,new A.ia()))return c3
a6=g.length
a8=A.d(new Array(a6),r)
for(n=0;n<a6;++n)a8[n]=a3.m(a5,n)-q.m(a0,n)
a3=c.m(0,a4)
a3.toString
a9=b.m(0,a)
b0=A.k(a3.a.i(0,a9.b),a3.b.i(0,a9.a))
a3=b0.a
if(a3.gt(0)>4096||b0.b.gt(0)>4096)return c3
a1.u(0,B.b.H(a8,","),b0)
for(a9=new A.b5(b,b.r,b.e,A.q(b).h("b5<1,2>")),b1=b0.b;a9.q();){b2=a9.d
b3=e.$1(b2.a)
a6=g.length
a7=A.d(new Array(a6),r)
for(b4=J.aj(b3),n=0;n<a6;++n){b5=b4.m(b3,n)
if(!(n<a8.length))return A.a(a8,n)
a7[n]=b5+a8[n]}b6=B.b.H(a7,",")
k=c.m(0,b6)
if(k==null)k=$.J()
b4=b2.b
b4=A.k(a3.i(0,b4.a),b1.i(0,b4.b))
b5=b4.b
b7=k.b
b8=A.k(k.a.i(0,b5).G(0,b4.a.i(0,b7)),b7.i(0,b5))
b4=b8.a
if(b4.gt(0)>4096||b8.b.gt(0)>4096)return c3
b4=b4.j(0,$.p())
if(b4===0)c.ad(0,b6)
else c.u(0,b6,b8)}}b9=new A.bm("")
for(r=new A.O(a1,a1.$ti.h("O<1,2>")).gC(0),q=t.s,m="";r.q();){c0=r.d
c1=e.$1(c0.a)
c2=A.d([],q)
m=c0.b
a3=m.a
a9=a3.a?a3.n(0):a3
m=m.b
b1=$.u()
b4=!1
b5=b1.a.j(0,a9)
if(b5===0)b1=b1.b.j(0,m)===0
else b1=b4
if(!b1||J.oB(c1,new A.ib())){b1=m.j(0,$.o())
B.b.l(c2,b1===0?a9.k(0):a9.k(0)+"/"+m.k(0))}for(m=J.aj(c1),n=0;n<g.length;++n)if(m.m(c1,n)>0){a9=m.m(c1,n)
b1=g.length
if(a9===1){if(!(n<b1))return A.a(g,n)
a9=g[n]}else{if(!(n<b1))return A.a(g,n)
a9=g[n]+"^"+m.m(c1,n)}B.b.l(c2,a9)}if(a3.gE(0)<0)m=b9.a+="-"
else{m=b9.a
if(m.length!==0){m+="+"
b9.a=m}}m+=B.b.H(c2,"*")
b9.a=m}r=m.length===0?"0":m.charCodeAt(0)==0?m:m
return new A.dX("("+i+") \u2260 0",r)},
i9:function i9(){},
i8:function i8(a){this.a=a},
ic:function ic(){},
id:function id(a){this.a=a},
ie:function ie(a){this.a=a},
ia:function ia(){},
ib:function ib(){},
pU(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f=a.length
if(f>2000)return g
for(s=0,r=-1,q=0;q<f;++q){p=a[q]
if(p==="(")++s
if(p===")")--s
if(s<0)return g
if((p==="+"||p==="-")&&s===0&&q>0){o=B.a.bS(B.a.F(a,0,q))
n=o.length
if(n!==0){m=n-1
if(!(m>=0))return A.a(o,m)
m=!B.a.J("+-*/^(",o[m])
n=m}else n=!1
if(n)return g}if(p==="/"&&s===0){if(r>=0)return g
r=q}}if(r<0||s!==0)return g
l=B.a.p(B.a.M(a,r+1))
k=A.bn(l)
if(k==null)return g
f=A.l("[a-zA-Z]+",!0).am(0,k)
n=t.N
m=A.q(f)
m=A.dl(f,m.h("i(m.E)").a(new A.il()),m.h("m.E"),n)
j=A.hn(m,A.q(m).h("m.E"))
f=j.a
if(f!==1)return g
i=j.gaD(0)
h=A.j4(k,i)
if(h==null||h.length===0)return g
return new A.ik(i,l,A.cb(h,n))},
ik:function ik(a,b,c){this.a=a
this.b=b
this.c=c},
il:function il(){},
iq(a){var s,r,q,p,o,n,m,l
for(s=a.a,r=s.length,q=0,p=0,o=0;o<r;++o){n=s[o]
m=n.a
l=(m.a?m.n(0):m).gt(0)
if(l>q)q=l
p+=n.b.gt(0)}return q+p+B.c.gt(r)},
mK(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=null,a0=!0
if(a1.length<=512)if(A.ed(a1))if(!B.a.J(a1,"/")){a0=A.l("\\^\\s*\\(?\\s*-\\d",!0)
f=A.A(a1,"**","^")
a0=!a0.b.test(f)}else a0=!1
if(a0)return a
try{e={}
s=A.d(a1.split("="),t.s)
if(J.S(s)>2)return a
r=J.S(s)===2?"("+J.aL(s,0)+")-("+J.aL(s,1)+")":a1
q=A.d([],t.k)
e.a=0
p=new A.im(a2)
o=new A.io()
n=new A.ip(e,p,a2,o,q)
m=null
l=null
k=n.$2(new A.bW(r).aN(),0)
m=k.a
l=k.b
if(l.a.length===0||m.a.length===0)return a
J.fo(q,l)
j=m
for(a0=q,f=a0.length,d=0;d<a0.length;a0.length===f||(0,A.M)(a0),++d){i=a0[d]
if(i.a.length===0)return a
h=0
for(;;){c=h
if(typeof c!=="number")return c.af()
if(!(c<8))break
g=A.mF(j,i)
if(g==null)return a
if(g.a.length-1<=0)break
j=j.Y(g).a
c=h
if(typeof c!=="number")return c.A()
h=c+1}}a0=j
return a0}catch(b){return a}},
im:function im(a){this.a=a},
io:function io(){},
ip:function ip(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
q8(a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=null,a1=A.q5(a3)
if(a1==null)return a0
s=A.mO(a1.a,a4)
r=A.mO(a1.b,a4)
if(s==null||r==null||r.a.length===0)return a0
if(r.a.length-1===0)return a0
q=r.gb_()
p=r.aT()
o=s.a_($.u().ac(0,q))
n=A.d([],t.s)
m=new A.k2(a4,n)
l=o.Y(p)
m.cs(l.a)
o=l.b
if(o.a.length===0)return n.length===0?"0":B.b.H(n," ")
k=A.q7(p)
j=A.d([],t.gq)
for(i=0;i<k.length;++i){h=k[i]
if(h.a.length-1>0)B.b.l(j,new A.R(h,i+1))}for(h=j.length,g=0;g<j.length;j.length===h||(0,A.M)(j),++g){f=j[g]
e=f.a
d=f.b
c=e.a1(d)
b=A.ln(p.Y(c).a.Y(c).b,c)
a=b==null?a0:b.a
if(a==null)return a0
if(!A.q_(a2,m,o.i(0,a).Y(c).b,e,d))return a0}return n.length===0?"0":B.b.H(n," ")},
q_(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j
for(s=e,r=c;s>1;){q=A.ln(d,d.ah())
if(q==null)return!1
p=q.a
o=r.i(0,q.b).Y(d.a1(s)).b
n=$.u();--s
m=A.C(s)
l=A.k(n.a.i(0,$.o()),n.b.i(0,m))
b.dQ(o.a_(new A.f(l.a.n(0),l.b)),d,s)
r=r.i(0,p).A(0,o.ah().a_(l)).Y(d.a1(s)).b}k=r.Y(d)
b.cs(k.a)
j=k.b
if(j.a.length===0)return!0
return A.q2(a,b,j,d)},
q2(a,b,c,d){var s,r,q,p,o,n,m,l,k,j=A.q0(a,d),i=j==null
if(i||B.b.X(j,new A.is())){if(A.q4(b,c,d))return!0
if(i)return!1}for(i=j.length,s=0;s<j.length;j.length===i||(0,A.M)(j),++s){r=j[s]
q=d.Y(r).a
p=q.a
o=p.length
if(o-1===0){n=$.u()
if(0>=o)return A.a(p,0)
p=p[0]
m=c.a_(A.k(n.a.i(0,p.b),n.b.i(0,p.a)))}else{l=A.ln(q.Y(r).b,r)
k=l==null?null:l.a
if(k==null)return!1
m=c.i(0,k).Y(r).b}p=m.a
o=p.length
if(o===0)continue
n=r.a.length-1
if(n===1){if(0>=o)return A.a(p,0)
b.bJ(p[0],r)}else if(n===2)b.dP(m,r)
else return!1}return!0},
q7(a){var s,r,q,p=t.k,o=A.d([],p),n=A.ll(a,a.ah())
if(n.a.length-1===0)return A.d([a],p)
s=A.mL(a,n)
r=A.mL(a.ah(),n).G(0,s.ah())
for(;;){q=A.ll(s,r)
B.b.l(o,q)
s=s.Y(q).a
if(s.a.length-1===0)break
r=r.Y(q).a.G(0,s.ah())}return o},
ln(a,b){var s,r,q,p,o,n,m,l,k,j,i=a.b,h=$.u(),g=A.dw(h,i),f=new A.G(B.h,i),e=new A.G(B.h,i)
h=A.dw(h,i)
for(s=b,r=a;s.a.length!==0;e=h,h=m,g=f,f=n,r=s,s=o){q=r.Y(s)
p=q.a
o=q.b
n=g.G(0,p.i(0,f))
m=e.G(0,p.i(0,h))}h=r.a
l=h.length
if(l-1!==0)return null
k=$.u()
if(0>=l)return A.a(h,0)
j=k.ac(0,h[0])
return new A.R(g.a_(j),e.a_(j))},
mL(a,b){return a.Y(b).a},
q4(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=c.ah(),f=c.a.length-1
if(f<1)return!1
s=A.d([],t.gs)
for(r=0;r<=f;++r){q=new A.f(A.C(r),$.o())
B.b.l(s,new A.R(q,A.pI(b.G(0,g.a_(q)),c)))}p=A.q1(s,"t")
o=p.a.length
if(o===0||o-1<1)return!1
n=A.q3(p)
if(n.length===0)return!1
m=A.d([],t.ca)
l=A.dw($.u(),c.b)
for(o=n.length,k=0;k<n.length;n.length===o||(0,A.M)(n),++k){j=n[k]
i=A.ll(c,b.G(0,g.a_(j))).aT()
if(i.a.length-1<1)continue
B.b.l(m,new A.R(j,i))
l=l.i(0,i)}if(m.length===0)return!1
if(A.bq(l)!==A.bq(c))return!1
for(o=m.length,k=0;k<m.length;m.length===o||(0,A.M)(m),++k){h=m[k]
a.bJ(h.a,h.b)}return!0},
q1(a,b){var s,r,q,p,o,n,m,l,k,j,i,h=new A.G(B.h,b)
for(s=t.j,r=t.G,q=0;q<a.length;++q){p=a[q].b
o=p.a.j(0,$.p())
if(o===0)n=new A.G(B.h,b)
else{m=A.bh([p],!1,r)
m.$flags=3
n=new A.G(m,b)}for(l=0;p=a.length,l<p;++l){if(l===q)continue
if(!(q<p))return A.a(a,q)
p=a[q].a
o=a[l].a
k=o.b
j=p.b
i=A.k(p.a.i(0,k).G(0,o.a.i(0,j)),j.i(0,k))
if(!(l<a.length))return A.a(a,l)
k=a[l].a
j=k.a.n(0)
o=$.u()
n=n.i(0,A.bj(A.d([new A.f(j,k.b),o],s),b).a_(A.k(o.a.i(0,i.b),o.b.i(0,i.a))))}h=h.A(0,n)}return h},
q3(a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b={},a=b.a=$.o()
for(s=a0.a,r=s.length,q=0;q<r;++q,a=n){p=s[q].b
o=a.aC(0,p)
if(o.c===0)A.x(B.e)
n=a.i(0,p.a2(o))
b.a=n}a=A.H(s)
r=a.h("t<1,a9>")
m=A.L(new A.t(s,a.h("a9(1)").a(new A.it(b)),r),r.h("D.E"))
l=B.b.gR(m)
if(l.a)l=l.n(0)
k=B.b.gP(m)
if(k.a)k=k.n(0)
a=$.p()
s=k.j(0,a)
if(s===0)k=$.o()
j=A.cK(t.G)
a=B.b.gP(m).j(0,a)
if(a===0)j.l(0,$.J())
i=A.mM(k)
h=A.mM(l)
for(a=i.length,q=0;q<i.length;i.length===a||(0,A.M)(i),++q){g=i[q]
for(s=h.length,f=0;f<h.length;h.length===s||(0,A.M)(h),++f){e=h[f]
for(r=$.o(),r=[r,r.n(0)],d=0;d<2;++d){c=A.k(r[d].i(0,g),e)
p=A.pY(a0,c).a.j(0,$.p())
if(p===0)j.l(0,c)}}}a=A.L(j,j.$ti.c)
return a},
mM(a){var s,r,q,p=a.a?a.n(0):a,o=t.W,n=A.d([],o)
for(s=$.o(),r=s;r.j(0,p)<=0;r=r.A(0,s)){q=p.W(0,r).j(0,$.p())
if(q===0)B.b.l(n,r)}return n.length===0?A.d([s],o):n},
pY(a,b){var s,r,q,p,o,n,m,l,k=$.J()
for(s=a.a,r=s.length-1,q=b.a,p=b.b;r>=0;--r){o=A.k(k.a.i(0,q),k.b.i(0,p))
n=s[r]
m=n.b
l=o.b
k=A.k(o.a.i(0,m).A(0,n.a.i(0,l)),l.i(0,m))}return k},
q0(a,b){var s,r,q=b.a.length-1
if(q===1)return A.d([b],t.k)
if(a.gaM()){s=A.pZ(a,b)
if(s!=null)return s}r=A.n_(A.bq(b))
if(r!=null){s=A.mN(r,b)
if(s!=null)return s}return q<=2?A.d([b],t.k):null},
pZ(a,b){var s,r,q,p,o,n,m=$.o()
for(s=b.a,r=s.length,q=0;q<r;++q){p=s[q].b
o=m.aC(0,p)
if(o.c===0)A.x(B.e)
m=m.i(0,p.a2(o))}n=a.cz(A.bq(b.a_(A.k(m,$.o()))))
if(B.a.v(n,"Error"))return null
return A.mN(n,b)},
mN(a,b){var s,r,q,p,o,n,m,l,k,j,i=null,h=b.b,g=A.d([],t.k),f=A.q6(A.A(a," ","")),e=f.length,d=0
for(;d<f.length;f.length===e||(0,A.M)(f),++d){s=f[d]
r=A.l("^\\((.*)\\)\\^(\\d+)$",!0).a3(s)
if(r!=null){q=r.b
p=q.length
if(1>=p)return A.a(q,1)
o=q[1]
o.toString
if(2>=p)return A.a(q,2)
q=q[2]
q.toString
n=A.eh(q,i,i)
m=o}else{m=B.a.v(s,"(")&&B.a.T(s,")")?B.a.F(s,1,s.length-1):s
n=1}l=A.cf(m)
if(l==null)return i
q=l.a.length-1
if(q===0)continue
if(l.b!==h&&q>0)return i
for(k=0;k<n;++k)B.b.l(g,l.aT())}j=A.dw($.u(),h)
for(f=g.length,d=0;d<g.length;g.length===f||(0,A.M)(g),++d)j=j.i(0,g[d])
if(A.bq(j)!==A.bq(b.aT()))return i
return g},
q6(a){var s,r,q,p,o,n=A.d([],t.s)
for(s=a.length,r=0,q=0,p=0;p<s;++p){o=a[p]
if(o==="(")++r
if(o===")")--r
if(o==="*"&&r===0){B.b.l(n,B.a.F(a,q,p))
q=p+1}}B.b.l(n,B.a.M(a,q))
s=t.cc
s=A.L(new A.cn(n,t.aN.a(new A.iu()),s),s.h("m.E"))
return s},
q5(a){var s,r,q,p,o,n,m,l=null
for(s=a.length,r=l,q=0,p=0;p<s;++p){o=a[p]
if(o==="("||o==="[")++q
if(o===")"||o==="]")--q
if(o==="/"&&q===0){if(r!=null)return l
r=p}}if(r==null)return l
n=B.a.p(B.a.F(a,0,r))
m=B.a.p(B.a.M(a,r+1))
if(n.length===0||m.length===0)return l
return new A.R(n,m)},
mO(a,b){var s,r,q,p,o,n,m,l,k=B.a.p(a)
for(;;){if(!(B.a.v(k,"(")&&B.a.T(k,")")))break
r=k.length
q=r-1
p=0
o=0
for(;;){if(!(o<r)){s=!0
break}n=k[o]
if(n==="(")++p
if(n===")")--p
if(p===0&&o<q){s=!1
break}++o}if(!s)break
k=B.a.p(B.a.F(k,1,q))}m=A.cf(k)
if(m==null){l=A.bn(k)
if(l==null)return null
m=A.cf(l)}if(m==null)return null
r=m.a
if(r.length-1>0&&m.b!==b)return null
return A.bj(r,b)},
fg(a){var s=a.b,r=s.j(0,$.o()),q=a.a
return r===0?q.k(0):q.k(0)+"/"+s.k(0)},
bq(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=a.a,f=g.length
if(f===0)return"0"
s=A.d([],t.s)
for(r=f-1,q=a.b,f=q+"^";r>=0;--r){p=g[r]
o=p.a
n=o.j(0,$.p())
if(n===0)continue
n=o.a?o.n(0):o
m=p.b
l=m.j(0,$.o())
k=l===0?n.k(0):n.k(0)+"/"+m.k(0)
if(r===0)j=k
else{i=r===1?q:f+r
l=$.u()
h=!1
n=l.a.j(0,n)
if(n===0)n=l.b.j(0,m)===0
else n=h
j=n?i:k+"*"+i}if(s.length===0)B.b.l(s,o.gE(0)<0?"-"+j:j)
else B.b.l(s,o.gE(0)<0?"- "+j:"+ "+j)}return B.b.H(s," ")},
nn(a){var s=a.a,r=a.b,q=s.i(0,r),p=A.r_(q),o=p.i(0,p).j(0,q)
if(o===0)return A.fg(A.k(p,r))
o=r.j(0,$.o())
if(o===0)return"sqrt("+s.k(0)+")"
return"(sqrt("+q.k(0)+")/"+r.k(0)+")"},
r_(a){var s,r,q
if(a.j(0,$.bO())<0)return a
s=a.A(0,$.o()).ak(0,1)
for(r=a;s.j(0,r)<0;r=s,s=q){if(s.c===0)A.x(B.e)
q=s.A(0,a.a2(s)).ak(0,1)}return r},
is:function is(){},
it:function it(a){this.a=a},
iu:function iu(){},
k2:function k2(a,b){this.a=a
this.b=b},
qd(a,b,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=null,e=t.s,d=A.d(["oo","inf","infinity","\\infty"],e),c=B.a.p(a0)
if(B.b.J(d,c))s=1
else s=B.b.J(A.d(["-oo","-inf","-infinity"],e),c)?-1:0
if(a.length>512||s===0)return f
e=A.bl(a)
r=A.A(e," ","")
for(e=r.length,q=0,p=-1,o=0;o<e;++o){d=r[o]
if(d==="(")++q
if(d===")")--q
if(d==="-"&&q===0&&o>0&&!B.a.J("+-*/^(",r[o-1])){if(p>=0)return f
p=o}}if(p<0||q!==0)return f
n=A.bl(B.a.F(r,0,p))
m=A.bl(B.a.M(r,p+1))
l=B.a.v(m,"sqrt(")&&B.a.T(m,")")
k=l?m:n
if(!B.a.v(k,"sqrt(")||!B.a.T(k,")"))return f
j=A.cg(B.a.F(k,5,k.length-1),b)
i=A.cg(l?n:m,b)
if(j==null||j.a.length-1!==2||i==null||i.a.length-1!==1)return f
e=i.a
if(1>=e.length)return A.a(e,1)
h=e[1]
if(h.a.gE(0)===s){d=j.a
if(2>=d.length)return A.a(d,2)
d=d[2].a.gE(0)<=0||!h.i(0,h).I(0,d[2])}else d=!0
if(d)return f
d=j.a
if(1>=d.length)return A.a(d,1)
g=d[1].ac(0,new A.f(A.C(2),$.o()).i(0,h)).G(0,e[0])
return(l?new A.f(g.a.n(0),g.b):g).k(0)},
bl(a){var s,r,q,p,o,n,m=B.a.p(a)
for(;;){if(!(B.a.v(m,"(")&&B.a.T(m,")")))break
for(s=m.length,r=s-1,q=0,p=!0,o=0;o<s;++o){n=m[o]
if(n==="(")++q
if(n===")")--q
if(q===0&&o<r)p=!1}if(!p||q!==0)break
m=B.a.p(B.a.F(m,1,r))}return m},
mR(a){var s,r,q,p,o,n=A.bl(a)
for(s=n.length,r=0,q=-1,p=0;p<s;++p){o=n[p]
if(o==="(")++r
if(o===")")--r
if(o==="*"&&r===0){if(q<0){o=p+1
o=o<s&&n[o]==="*"}else o=!0
if(o)return null
q=p}}return q<0?null:A.d([B.a.F(n,0,q),B.a.M(n,q+1)],t.s)},
cg(a,b){var s,r,q
if(a.length>512||!A.ed(a))return null
s=A.bn(a)
r=s==null?null:A.cf(s)
if(r!=null)q=r.a.length-1>0&&r.b!==b
else q=!0
return q?null:r},
mQ(a,b){return A.kU(a,A.l("([0-9])\\s*("+A.a2(b)+")(?![A-Za-z_0-9])",!0),t.A.a(t.I.a(new A.iv())),null)},
dA(a,b,c){if(a.length>512)return null
return A.aX(A.kU(A.mQ(a,b),A.l("[A-Za-z_][A-Za-z_0-9]*",!0),t.A.a(t.I.a(new A.iA(b,c))),null))},
qe(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g,f
if(a.length<=512){s=A.l("^[A-Za-z]$",!0)
s=!s.b.test(b)}else s=!0
if(s)return!1
r=A.mR(a)
if(r==null)return!1
for(s=t.N,q=t.V,p=0;p<2;++p){o=A.bl(r[p])
n=A.l("^(?:sin|cos)\\((.*)\\)$",!0).a3(o)
if(n==null)continue
m=A.cg(r[1-p],b)
if(m==null||A.dA(m.k(0),b,c)!=="0")continue
l=n.b
if(1>=l.length)return A.a(l,1)
l=l[1]
l.toString
k=A.l("^[0-9.\\s()+*/^\\-"+A.a2(b)+"]+$",!0)
if(!k.b.test(l))continue
j=A.l("\\^\\s*(?:\\([+-]?\\d+\\)|[+-]?\\d+)(?![\\d.])",!0).am(0,l).gB(0)
if(B.a.am("^",l).gB(0)!==j)continue
i=A.au(l)
l=A.au(c)
if(l==null)h=null
else h=l.K(B.u)
if(i==null||h==null||!isFinite(h))continue
g=i.K(A.B([b,h-0.125],s,q))
f=i.K(A.B([b,h+0.125],s,q))
if(g!=null&&f!=null&&isFinite(g)&&isFinite(f))return!0}return!1},
mP(a,b){var s,r,q,p,o,n,m,l
if(a.length>512)return null
s=A.bl(a)
r=A.mR(s)
if(r!=null)if(B.a.v(A.bl(r[0]),"abs(")){q=A.bl(r[0])
p=r[1]}else{q=A.bl(r[1])
p=r[0]}else{q=s
p="1"}o=A.l("^abs\\((.*)\\)$",!0).a3(q)
if(o==null)return null
n=o.b
if(1>=n.length)return A.a(n,1)
n=n[1]
n.toString
m=A.cg(n,b)
l=A.cg(p,b)
if(m!=null){n=m.a.length-1
n=n<1||n>8||l==null||l.a.length-1>16}else n=!0
if(n)return null
return new A.dY(m,l)},
qa(a,b,c){var s,r,q,p,o,n,m,l,k,j=null,i=A.mP(a,b)
if(i==null)return j
s=i.a
r=A.dA(s.k(0),b,c)
if(r==null)return j
if(r==="0"){q=s
p=r
o=0
for(;;){n=p==="0"
if(!(n&&q.a.length!==0))break
q=q.ah();++o
m=A.dA(q.k(0),b,c)
if(m==null)return j
p=m}if((o&1)===1||n)return j}else p=r
l=B.a.v(p,"-")?"-1":"1"
k=A.bn("("+l+")*("+i.b.k(0)+")*("+s.k(0)+")")
return k==null?j:A.mQ(k,b)},
qb(a,b,c,d){var s,r,q,p,o,n,m=null,l=A.mP(a,b)
if(l==null||A.dA(l.a.k(0),b,c)!=="0")return m
if(d<0||d>64)return m
s=l.a
for(r=0;s.a.length!==0;){q=A.dA(s.k(0),b,c)
if(q==null)return m
if(q!=="0")break;++r
s=s.ah()}if((r&1)===0)return m
p=l.b
for(o=0;n=p.a.length!==0,n;){q=A.dA(p.k(0),b,c)
if(q==null)return m
if(q!=="0")break;++o
p=p.ah()}return!n||d<o+r?"0":"Error: derivative does not exist at "+b+" = "+c+" (order "+d+")"},
qc(a,b,c,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null
if(a.length>512)return d
s=A.bl(a)
s=A.A(s," ","")
r=A.A(s,"**","^")
q=A.q9(r,b,c,a0)
if(q!=null)return q
p=A.l("^(1/)?(sqrt|ln|log)\\((.*)\\)(?:\\^(\\d+)|\\^\\((\\d+)\\))?$",!0).a3(r)
if(p!=null){s=p.b
o=s.length
if(1>=o)return A.a(s,1)
if(s[1]!=null){if(2>=o)return A.a(s,2)
s=s[2]!=="sqrt"}else s=!1}else s=!0
if(s)return d
s=p.b
o=s.length
if(4>=o)return A.a(s,4)
n=s[4]
if(n==null){if(5>=o)return A.a(s,5)
o=s[5]}else o=n
m=A.bk(o==null?"1":o,d)
o=!0
if(m!=null)if(!(m>8)){n=s.length
if(2>=n)return A.a(s,2)
if(s[2]==="sqrt"){if(4>=n)return A.a(s,4)
if(s[4]==null){if(5>=n)return A.a(s,5)
o=s[5]!=null}}else o=!1}if(o)return d
if(3>=s.length)return A.a(s,3)
s=s[3]
s.toString
l=A.cg(s,b)
if(l==null||l.a.length-1!==1)return d
k=A.bV(c)
j=A.bV(a0)
s=l.a
if(1>=s.length)return A.a(s,1)
i=s[1].a.aB(0)/s[1].b.aB(0)
h=s[0].a.aB(0)/s[0].b.aB(0)
if(k==null||j==null||!isFinite(k)||!isFinite(j)||!isFinite(i)||i===0||!isFinite(h))return d
g=i*k+h
f=i*j+h
if(!isFinite(g)||!isFinite(f))return d
s=!0
if(!(g<0))if(!(f<0))s=g===0&&f===0
if(s)return new A.bp(u.a,d)
s=new A.iB(p,m,i)
o=s.$1(f)
s=s.$1(g)
if(typeof o!=="number")return o.G()
if(typeof s!=="number")return A.aU(s)
e=o-s
return isFinite(e)?new A.bp(d,e):d},
q9(b8,b9,c0,c1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7=null
for(s=b8.length,r=0,q=-1,p=0;p<s;++p){o=b8[p]
if(o==="(")++r
if(o===")")--r
if(r<0)return b7
if(o==="/"&&r===0){if(q>=0)return b7
q=p}}if(r!==0||q<0)return b7
n=A.bl(B.a.F(b8,0,q))
m=A.l("^(?:ln|log)\\((.*)\\)(?:\\^(\\d+)|\\^\\((\\d+)\\))?$",!0).a3(n)
if(m==null)return b7
s=m.b
o=s.length
if(2>=o)return A.a(s,2)
l=s[2]
if(l==null){if(3>=o)return A.a(s,3)
o=s[3]}else o=l
k=A.bk(o==null?"1":o,b7)
if(k==null||k>8)return b7
if(1>=s.length)return A.a(s,1)
s=s[1]
s.toString
j=A.cg(s,b9)
i=A.cg(B.a.M(b8,q+1),b9)
s=!0
if(j!=null){o=j.a
l=o.length
if(l-1===1)if(i!=null){h=i.a
g=h.length
if(g-1===1){if(0>=g)return A.a(h,0)
s=h[0]
if(1>=l)return A.a(o,1)
s=s.i(0,o[1])
if(1>=g)return A.a(h,1)
o=!s.I(0,h[1].i(0,o[0]))
s=o}}}if(s)return b7
f=new A.iw()
e=f.$1(c0)
d=f.$1(c1)
if(e==null||d==null||e.I(0,d))return b7
s=j.a
if(1>=s.length)return A.a(s,1)
c=s[1].i(0,e).A(0,s[0])
b=s[1].i(0,d).A(0,s[0])
s=c.a
if(s.gE(0)<0||b.a.gE(0)<0)return new A.bp(u.a,b7)
o=$.p()
l=s.j(0,o)
if(l!==0)o=b.a.j(0,o)===0
else o=!0
if(o)return new A.bp("Error: logarithmic endpoint integral is divergent",b7)
a=new A.iy()
a0=new A.iz(a)
a1=new A.ix()
o=b.a
l=c.b
if(a1.$2(o,l)){h=b.b
h=!a1.$2(h,s)||!a1.$2(o,s)||!a1.$2(h,l)}else h=!0
if(h)return b7
a2=k+1
h=(a2&1)===0
if(h)s=o.i(0,s).j(0,b.b.i(0,l))===0
else s=!1
if(s)return new A.bp(b7,0)
a3=a0.$1(c)
a4=a0.$1(b)
a5=a0.$1(b.ac(0,c))
if(a3==null||a4==null||a5==null||!isFinite(a3)||!isFinite(a4)||!isFinite(a5)||a5===0)return b7
a6=Math.max(Math.abs(a3),Math.abs(a4))
if(a6===0||!isFinite(a6))return b7
a7=a3/a6
a8=a4/a6
a9=a2-1
b0=0
if(h&&J.aN(a3)!==J.aN(a4)){b1=a0.$1(c.i(0,b))
if(b1==null||b1===0||!isFinite(b1))return b7
b2=Math.log(Math.abs(b1))
b3=J.aN(b1)
a9=a2-2
for(s=B.c.S(a2,2),b4=0;b4<s;++b4){o=2*b4
b0+=Math.pow(a8,a9-o)*Math.pow(a7,o)}}else{for(b4=0;b4<a2;++b4)b0+=Math.pow(a8,a9-b4)*Math.pow(a7,b4)
b2=0
b3=1}if(b0===0||!isFinite(b0))return b7
s=i.a
if(1>=s.length)return A.a(s,1)
b5=s[1]
s=b5.a
o=a.$1(s.a?s.n(0):s)
l=a.$1(b5.b)
if(typeof o!=="number")return o.G()
if(typeof l!=="number")return A.aU(l)
b6=Math.exp(Math.log(Math.abs(a5))+a9*Math.log(a6)+b2+Math.log(Math.abs(b0))-(o-l)-Math.log(a2))
if(!isFinite(b6)||b6===0)return b7
return new A.bp(b7,b6*J.aN(a5)*J.aN(b0)*b3*s.gE(0))},
iv:function iv(){},
iA:function iA(a,b){this.a=a
this.b=b},
iB:function iB(a,b,c){this.a=a
this.b=b
this.c=c},
iw:function iw(){},
iy:function iy(){},
iz:function iz(a){this.a=a},
ix:function ix(){},
ch:function ch(a,b){this.a=a
this.b=b},
aW:function aW(a,b){this.a=a
this.b=b},
ax:function ax(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
fP:function fP(a,b){this.a=a
this.b=b},
eT(a){var s,r=B.a.p(a)
if(r==="0"||r==="0.0"||r==="-0")return!0
s=A.am(r)
return s!=null&&s===0},
cQ(e2,e3,e4,e5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,d0,d1,d2,d3,d4,d5,d6,d7,d8=null,d9="(?![a-zA-Z_0-9])",e0="Error",e1=A.a6(B.a.p(e2))
if(B.a.v(e1,"-")&&e1.length>1){s=B.a.p(B.a.M(e1,1))
B.b.l(e5,new A.a1())
r=A.cQ(s,e3,e4,e5)
return r==null?d8:"-("+r+")"}q=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
if(!q.b.test(e1)){q=t.N
A.B(["expr",e1,"var",e3],q,q)
B.b.l(e5,new A.a1())
return"("+e1+")\xb7"+e3}if(e1===e3){B.b.l(e5,new A.a1())
return"("+e3+")^2/2"}p=A.eV(e1)
if(p!=null&&p.length>=2){q=A.H(p)
new A.t(p,q.h("i(1)").a(new A.iL(e3)),q.h("t<1,i>")).H(0," ")
B.b.l(e5,new A.a1())
o=A.d([],t.s)
q=p.length
m=0
for(;;){if(!(m<p.length)){n=!0
break}l=p[m]
k=A.cQ(l.b,e3,e4,e5)
if(k==null){n=!1
break}B.b.l(o,l.a+"("+k+")")
p.length===q||(0,A.M)(p);++m}return n?B.b.H(o," "):d8}j=A.iF(e1)
if(j!=null){q=t.s
i=A.d([],q)
h=A.d([],q)
for(q=j.length,m=0;m<j.length;j.length===q||(0,A.M)(j),++m){g=j[m]
f=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
B.b.l(f.b.test(g)?h:i,g)}if(i.length!==0&&h.length!==0){e=B.b.H(i,"\xb7")
d=B.b.H(h,"\xb7")
q=t.N
A.B(["const",e],q,q)
B.b.l(e5,new A.a1())
r=A.cQ(d,e3,e4,e5)
return r==null?d8:"("+e+")\xb7("+r+")"}}c=A.dD(e1,"^")
if(c!=null){b=c.a
a=c.b
if(b===e3){q=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
q=!q.b.test(a)}else q=!1
if(q){q=B.a.p(a)
if(q==="-1"||q==="(-1)"){q=t.N
A.B(["var",e3],q,q)
B.b.l(e5,new A.a1())
return"ln|"+e3+"|"}a0=e4.a6("("+a+") + 1")
a1=B.a.v(a0,e0)?a+" + 1":a0
B.b.l(e5,new A.a1())
return"("+e3+")^("+a1+")/("+a1+")"}a2=A.iD(b,e3)
if(a2!=null){q=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
q=!q.b.test(a)}else q=!1
if(q){a3=A.a6(b)
q=B.a.p(a)
if(q==="-1"||q==="(-1)"){q=t.N
A.B(["u",a3,"slope",a2,"var",e3],q,q)
B.b.l(e5,new A.a1())
return"ln|"+a3+"|/("+a2+")"}a0=e4.a6("("+a+") + 1")
a1=B.a.v(a0,e0)?a+" + 1":a0
q=t.N
A.B(["u",a3,"slope",a2,"var",e3],q,q)
B.b.l(e5,new A.a1())
return"("+a3+")^("+a1+")/(("+a2+")\xb7("+a1+"))"}}a4=A.dD(e1,"/")
if(a4!=null){a5=B.a.p(a4.a)
a6=B.a.p(a4.b)
q=a5==="1"
if(q&&a6===e3){q=t.N
A.B(["var",e3],q,q)
B.b.l(e5,new A.a1())
return"ln|"+e3+"|"}if(q){a7=A.a6(a6)
a2=A.iD(a6,e3)
if(a2!=null){q=t.N
A.B(["u",a7,"slope",a2,"var",e3],q,q)
B.b.l(e5,new A.a1())
return"ln|"+a7+"|/("+a2+")"}}}a8=A.eU(e1)
q=a8!=null
if(q&&B.a.p(a8.b)===e3&&$.d4().a8(a8.a)){q=$.d4()
f=a8.a
a9=q.m(0,f).c.$1(e3)
q=t.N
A.B(["fn",f],q,q)
B.b.l(e5,new A.a1())
return a9}if(q&&$.d4().a8(a8.a)){f=a8.b
a2=A.iD(f,e3)
if(a2!=null){q=$.d4()
b0=a8.a
b1=q.m(0,b0).c.$1(f)
q=t.N
A.B(["u",f,"slope",a2,"var",e3,"fn",b0],q,q)
B.b.l(e5,new A.a1())
return"("+b1+")/("+a2+")"}}b2=A.iF(e1)
if(b2!=null&&b2.length===2)for(b3=0;b3<2;++b3){if(!(b3<b2.length))return A.a(b2,b3)
b4=A.a6(B.a.p(b2[b3]))
f=1-b3
if(!(f<b2.length))return A.a(b2,f)
b5=A.a6(B.a.p(b2[f]))
r=A.eU(b4)
if(r==null)continue
f=$.d4()
b0=r.a
if(!f.a8(b0))continue
b6=r.b
if(B.a.p(b6)===e3)continue
if(A.iD(b6,e3)!=null)continue
b7=e4.a7(b6,e3)
if(B.a.v(b7,e0))continue
b8=e4.a6("("+b5+") / ("+b7+")")
if(B.a.v(b8,e0))continue
b9=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
if(b9.b.test(b8))continue
b1=f.m(0,b0).c.$1(b6)
a9=b8==="1"?b1:"("+b8+")\xb7("+b1+")"
q=t.N
A.B(["u",b6,"du",b7,"var",e3,"fn",b0,"ratio",b8],q,q)
B.b.l(e5,new A.a1())
return a9}c0=A.dD(e1,"/")
if(c0!=null){a5=B.a.p(c0.a)
a6=B.a.p(c0.b)
f=!1
if(a5!=="1"){b0=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
if(b0.b.test(a5)){f=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
f=f.b.test(a6)}}if(f){c1=e4.a7(a6,e3)
if(!B.a.v(c1,e0)){b8=e4.a6("("+a5+") / ("+c1+")")
if(!B.a.v(b8,e0)){f=A.l("(?<![a-zA-Z_])"+A.a2(e3)+d9,!0)
f=!f.b.test(b8)}else f=!1
if(f){a7=A.a6(a6)
a9=b8==="1"?"ln|"+a7+"|":"("+b8+")\xb7ln|"+a7+"|"
q=t.N
A.B(["den",a7,"ratio",b8,"var",e3],q,q)
B.b.l(e5,new A.a1())
return a9}}}}c2=A.dD(e1,"/")
if(c2!=null){c3=A.qk(c2.a,c2.b,e3,e4,e5,e1)
if(c3!=null)return c3}c4=A.ql(e1,e3,e4,e5)
if(c4!=null)return c4
c5=A.dD(e1,"/")
if(c5!=null){c6=A.qi(c5.a,c5.b,e3,e4,e5,e1)
if(c6!=null)return c6}if(q){q=a8.a
q=(q==="ln"||q==="log")&&B.a.p(a8.b)===e3}else q=!1
if(q){q=t.N
A.B(["var",e3],q,q)
B.b.l(e5,new A.a1())
return e3+"\xb7ln("+e3+") - "+e3}c7=A.iF(e1)
if(c7!=null&&c7.length===2)for(b3=0;b3<2;++b3){if(!(b3<c7.length))return A.a(c7,b3)
c8=A.a6(B.a.p(c7[b3]))
q=1-b3
if(!(q<c7.length))return A.a(c7,q)
c9=A.a6(B.a.p(c7[q]))
d0=A.qj(c8,e3)
if(d0==null)continue
d1=A.eU(c9)
if(d1==null||B.a.p(d1.b)!==e3)continue
q=$.d4()
f=d1.a
if(!q.a8(f))continue
d2=q.m(0,f).c.$1(e3)
if(d0===1){q=t.N
A.B(["var",e3,"right",c9,"v",d2],q,q)
B.b.l(e5,new A.a1())
d3=A.cQ(d2,e3,e4,e5)
if(d3==null)return d8
return"("+e3+")\xb7("+d2+") - ("+d3+")"}q=e3+"^"
f=A.r(d0)
d4=q+f
d5=d0===2?e3:q+(d0-1)
d6=f+"*"+d5+"*("+d2+")"
q=t.N
A.B(["u",d4,"n",f,"right",c9,"v",d2,"var",e3],q,q)
B.b.l(e5,new A.a1())
d7=e4.a6(d6)
d3=A.cQ(B.a.v(d7,e0)?d6:d7,e3,e4,e5)
if(d3==null)return d8
return"("+d4+")\xb7("+d2+") - ("+d3+")"}B.b.l(e5,new A.a1())
return d8},
qk(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i,h,g="(?![a-zA-Z_0-9])"
if(A.a6(B.a.p(a))!=="1")return null
s=A.a6(B.a.p(b))
r=A.eV(s)
if(r!=null&&r.length===2){for(q=c+"^2",p=-1,o=-1,n=0;n<2;++n){if(!(n<r.length))return A.a(r,n)
m=B.a.p(A.a6(r[n].b))
if(m===q){if(!(n<r.length))return A.a(r,n)
l=r[n].a==="+"}else l=!1
if(l)p=n
else{l=A.l("(?<![a-zA-Z_])"+A.a2(c)+g,!0)
if(!l.b.test(m)){if(!(n<r.length))return A.a(r,n)
l=r[n].a==="+"}else l=!1
if(l)o=n}}if(p>=0&&o>=0){if(!(o>=0&&o<r.length))return A.a(r,o)
k=B.a.p(A.a6(r[o].b))
j=d.a6("sqrt("+k+")")
if(!B.a.v(j,"Error")){q=t.N
A.B(["aSq",k,"a",j,"var",c],q,q)
B.b.l(e,new A.a1())
return"atan("+c+"/("+j+"))/("+j+")"}}}i=A.eU(s)
if(i!=null&&i.a==="sqrt"){h=A.eV(A.a6(B.a.p(i.b)))
if(h!=null&&h.length===2){for(q=c+"^2",p=-1,o=-1,n=0;n<2;++n){if(!(n<h.length))return A.a(h,n)
m=B.a.p(A.a6(h[n].b))
if(m===q){if(!(n<h.length))return A.a(h,n)
l=h[n].a==="-"}else l=!1
if(l)p=n
else{l=A.l("(?<![a-zA-Z_])"+A.a2(c)+g,!0)
if(!l.b.test(m)){if(!(n<h.length))return A.a(h,n)
l=h[n].a==="+"}else l=!1
if(l)o=n}}if(p>=0&&o>=0){if(!(o>=0&&o<h.length))return A.a(h,o)
k=B.a.p(A.a6(h[o].b))
j=d.a6("sqrt("+k+")")
if(!B.a.v(j,"Error")){q=t.N
A.B(["aSq",k,"a",j,"var",c],q,q)
B.b.l(e,new A.a1())
return"asin("+c+"/("+j+"))"}}}}return null},
qi(c4,c5,c6,c7,c8,c9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7,b8=null,b9="(?![a-zA-Z_0-9])",c0="Error",c1=A.a6(B.a.p(c4)),c2=A.a6(B.a.p(c5)),c3=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
if(!c3.b.test(c2))return b8
s=c7.a7(c2,c6)
if(B.a.v(s,c0))return b8
r=c7.a7(s,c6)
if(B.a.v(r,c0))return b8
if(A.eT(r))return b8
c3=t.p
q=A.cK(c3)
for(p=-20;p<=20;++p){o=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
if(A.eT(c7.K(A.A(c2,o,"("+p+")"))))q.l(0,p)}if(q.a===0)return b8
n=A.X(c3,c3)
for(c3=A.f9(q,q.r,q.$ti.c),m="("+c6+" - ",l=c3.$ti.c;c3.q();){k=c3.d
if(k==null)k=l.a(k)
for(j=A.r(k),i=m+j+")",h=k===0,j="("+j+")",g=c2,f=0,e=0;e<5;++e,g=c){o=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
if(!A.eT(c7.K(A.A(g,o,j))))break;++f
d=h?c6:i
c=c7.a6("("+g+") / ("+d+")")
if(B.a.v(c,c0))break}if(f>0)n.u(0,k,f)}if(n.a===0)return b8
c3=t.s
b=A.d([],c3)
a=A.d([],c3)
for(c3=n.$ti.h("O<1,2>"),m=new A.O(n,c3).gC(0),l="("+c1+") * (",k=c6+" ";m.q();){a0=m.d
p=a0.a
a1=a0.b
a2=k+(p>=0?"-":"+")+" "+Math.abs(p)
if(a1===1){o=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
j="("+p+")"
a3=c7.K(A.A(s,o,j))
if(A.eT(a3))continue
o=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
a4=c7.K(A.A(c1,o,j))
if(B.a.v(a4,c0)||B.a.v(a3,c0))return b8
a5=c7.a6("("+a4+") / ("+a3+")")
if(B.a.v(a5,c0))return b8
j="("+a5
B.b.l(b,j+")/("+a2+")")
if(a5==="1")B.b.l(a,"ln|"+a2+"|")
else if(a5==="-1")B.b.l(a,"-ln|"+a2+"|")
else B.b.l(a,j+")\xb7ln|"+a2+"|")}else{a6=c7.a6(l+a2+")^"+a1+" / ("+c2+")")
if(B.a.v(a6,c0))return b8
for(j=a1-1,h="("+p+")",a7="-ln|"+a2+"|",a8="ln|"+a2+"|",a9=a6,e=0;e<a1;++e){o=A.l("(?<![a-zA-Z_])"+A.a2(c6)+b9,!0)
b0=c7.K(A.A(a9,o,h))
if(B.a.v(b0,c0))return b8
for(b1=1,b2=2;b2<=e;++b2)b1*=b2
a5=c7.a6("("+b0+") / "+b1)
if(B.a.v(a5,c0))return b8
b3=a1-e
if(!A.eT(a5)){b4="("+a5
b5=b4+")/("
if(b3===1){B.b.l(b,b5+a2+")")
if(a5==="1")B.b.l(a,a8)
else if(a5==="-1")B.b.l(a,a7)
else B.b.l(a,b4+")\xb7ln|"+a2+"|")}else{B.b.l(b,b5+a2+")^"+b3)
b5=""+(1-b3)
B.b.l(a,b4+")\xb7("+a2+")^("+b5+")/("+b5+")")}}if(e<j){a9=c7.a7(a9,c6)
if(B.a.v(a9,c0))return b8}}}}if(b.length===0)return b8
B.b.H(b," + ")
b6=B.b.H(a," + ")
m=t.N
c3=A.dl(new A.O(n,c3),c3.h("i(m.E)").a(new A.iE()),c3.h("m.E"),m)
b7=A.L(c3,A.q(c3).h("m.E"))
B.b.aV(b7)
A.r(b7)
A.B(["roots",B.b.H(b7,", ")],m,m)
B.b.l(c8,new A.a1())
B.b.l(c8,new A.a1())
return b6},
ql(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h=null,g=A.eU(B.a.p(a))
if(g==null||g.a!=="sqrt")return h
s=A.eV(A.a6(B.a.p(g.b)))
if(s==null||s.length!==2)return h
for(r=b+"^2",q=h,p=q,o=0;o<2;++o){if(!(o<s.length))return A.a(s,o)
n=B.a.p(A.a6(s[o].b))
if(n===r)p=o
else{m=A.l("(?<![a-zA-Z_])"+A.a2(b)+"(?![a-zA-Z_0-9])",!0)
if(!m.b.test(n))q=o}}if(p==null||q==null)return h
if(q>>>0!==q||q>=s.length)return A.a(s,q)
l=B.a.p(A.a6(s[q].b))
k=c.a6("sqrt("+l+")")
if(B.a.v(k,"Error"))return h
r=s.length
if(p>>>0!==p||p>=r)return A.a(s,p)
j=s[p].a
if(q>>>0!==q||q>=r)return A.a(s,q)
i=s[q].a
r=i==="+"
if(r&&j==="-"){r=t.N
A.B(["aSq",l,"a",k],r,r)
B.b.l(d,new A.a1())
return"("+b+"/2)*sqrt("+l+" - "+b+"^2) + ("+l+"/2)*asin("+b+"/("+k+"))"}if(r&&j==="+"){r=t.N
A.B(["aSq",l,"a",k],r,r)
B.b.l(d,new A.a1())
return"("+b+"/2)*sqrt("+l+" + "+b+"^2) + ("+l+"/2)*ln(abs("+b+" + sqrt("+l+" + "+b+"^2)))"}if(j==="+"&&i==="-"){r=t.N
A.B(["aSq",l,"a",k],r,r)
B.b.l(d,new A.a1())
return"("+b+"/2)*sqrt("+b+"^2 - "+l+") - ("+l+"/2)*ln(abs("+b+" + sqrt("+b+"^2 - "+l+")))"}return h},
qj(a,b){var s,r,q=null,p=A.a6(B.a.p(a))
if(p===b)return 1
s=A.dD(p,"^")
if(s==null)return q
if(B.a.p(A.a6(s.a))!==b)return q
r=A.bk(B.a.p(A.a6(s.b)),q)
if(r==null||r<1||r>9)return q
return r},
iD(a0,a1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=null,b="(?![a-zA-Z_0-9])",a=A.a6(B.a.p(a0))
if(a===a1)return c
s=A.l("(?<![a-zA-Z_])"+A.a2(a1)+b,!0)
if(!s.b.test(a))return c
r=A.eV(a)
if(r==null)r=A.d([new A.bK("+",a)],t.d8)
for(s=r.length,q=t.s,p=c,o=!1,n=0;n<r.length;r.length===s||(0,A.M)(r),++n){m=r[n]
l=A.a6(m.b)
k=A.l("(?<![a-zA-Z_])"+A.a2(a1)+b,!0)
if(!k.b.test(l))continue
j=A.iF(l)
if(j==null)j=A.d([l],q)
for(k=j.length,i=c,h=!1,g=0;g<j.length;j.length===k||(0,A.M)(j),++g){f=A.a6(j[g])
if(f===a1){if(h)return c
h=!0}else{e=A.l("(?<![a-zA-Z_])"+A.a2(a1)+b,!0)
if(e.b.test(f))return c
else i=i==null?f:"("+i+")\xb7("+f+")"}}if(!h)return c
d=i==null?"1":i
if(m.a==="-")d="-("+d+")"
p=p==null?d:"("+p+") + ("+d+")"
o=!0}return o?p:c},
a6(a){var s,r,q,p,o,n,m=B.a.p(a)
for(;;){s=m.length
if(!(s>=2&&B.a.v(m,"(")&&B.a.T(m,")")))break
q=s-1
p=0
o=0
for(;;){if(!(o<s)){r=!0
break}n=m[o]
if(n==="(")++p
if(n===")"){--p
if(p===0&&o!==q){r=!1
break}}++o}if(!r)break
m=B.a.p(B.a.F(m,1,q))}return m},
eV(a){var s,r,q,p,o,n,m,l,k,j=A.d([],t.d8)
for(s=a.length,r=0,q=0,p="+",o=0;o<s;++o){n=a[o]
if(n==="("||n==="[")++r
if(n===")"||n==="]")--r
m=!1
if(r===0)if(o>0)m=n==="+"||n==="-"
if(m){m=o-1
if(!(m>=0))return A.a(a,m)
l=a[m]
if(l==="*"||l==="/"||l==="^"||l==="("||l==="e"||l==="E")continue
k=B.a.p(B.a.F(a,q,o))
if(k.length!==0)B.b.l(j,new A.bK(p,k))
q=o+1
p=n}}k=B.a.p(B.a.M(a,q))
if(k.length!==0)B.b.l(j,new A.bK(p,k))
return j.length>=2?j:null},
dD(a,b){var s,r,q,p
for(s=a.length,r=0,q=0;q<s;++q){p=a[q]
if(p==="("||p==="[")++r
if(p===")"||p==="]")--r
if(r===0&&p===b&&q>0)return new A.jm(B.a.p(B.a.F(a,0,q)),B.a.p(B.a.M(a,q+1)))}return null},
iF(a){var s,r,q,p,o,n,m,l=A.d([],t.s)
for(s=a.length,r=0,q=0,p=0;p<s;++p){o=a[p]
if(o==="("||o==="[")++r
if(o===")"||o==="]")--r
if(r===0&&o==="*"){n=B.a.p(B.a.F(a,q,p))
if(n.length!==0)B.b.l(l,n)
q=p+1}}m=B.a.p(B.a.M(a,q))
if(m.length!==0)B.b.l(l,m)
return l.length>=2?l:null},
eU(a){var s,r,q,p,o,n,m=A.l("^([a-zA-Z_][a-zA-Z0-9_]*)\\(",!0).ef(0,a)
if(m==null)return null
s=m.b
if(1>=s.length)return A.a(s,1)
s=s[1]
s.toString
r=m.gaK()
q=a.length
p=r
o=1
for(;;){if(!(p<q&&o>0))break
if(!(p>=0&&p<q))return A.a(a,p)
n=a[p]
if(n==="(")++o
if(n===")")--o;++p}if(o!==0||p!==q)return null
return new A.jt(s,B.a.F(a,r,p-1))},
fc(a,b,c){return new A.fb(c,b,a)},
a1:function a1(){},
iL:function iL(a){this.a=a},
iE:function iE(){},
iG:function iG(){},
iH:function iH(){},
iI:function iI(){},
iJ:function iJ(){},
iK:function iK(){},
bK:function bK(a,b){this.a=a
this.b=b},
jm:function jm(a,b){this.a=a
this.b=b},
jt:function jt(a,b){this.a=a
this.b=b},
fb:function fb(a,b,c){this.a=a
this.b=b
this.c=c},
mT(a){return new A.v(a)},
iW(a,b){return new A.bD(a,b)},
nV(a){var s,r,q,p,o,n,m
if(a instanceof A.v)return new A.R(a.a,null)
if(a instanceof A.a_){s=$.u()
r=A.d([],t.h)
for(q=a.a,p=q.length,o=0;o<q.length;q.length===p||(0,A.M)(q),++o){n=q[o]
if(n instanceof A.v){m=n.a
s=A.k(s.a.i(0,m.a),s.b.i(0,m.b))}else B.b.l(r,n)}q=r.length
if(q===0)return new A.R(s,null)
if(q===1)return new A.R(s,B.b.gP(r))
return new A.R(s,new A.a_(r))}return new A.R($.u(),a)},
rZ(a){if(a instanceof A.a7)return new A.R(a.a,a.b)
return new A.R(a,$.ej())},
rN(a,b){var s,r,q,p,o,n,m,l=$.o(),k=b.b.j(0,l)
if(k!==0)return null
s=b.a
k=s.a
r=k?s.n(0):s
if(r.j(0,A.C(4096))>0)return null
r=a.a
q=$.p()
p=r.j(0,q)
if(p===0)return s.j(0,q)>0?$.J():null
o=(k?s.n(0):s).ai(0)
for(k=a.b,n=l,m=0;m<o;++m){l=l.i(0,r)
n=n.i(0,k)}return s.j(0,$.p())>0?A.k(l,n):A.k(n,l)},
rl(a,b){var s,r,q,p,o,n,m,l=null
if(b.length===1&&B.b.gP(b) instanceof A.v&&B.hT.J(0,a))if(t.w.a(B.b.gP(b)).a.a.gE(0)<=0)throw A.c(A.iW(B.z,a))
if(B.b.az(b,new A.kb())){s=A.H(b)
r=s.h("t<1,f>")
q=A.L(new A.t(b,s.h("f(1)").a(new A.kc()),r),r.h("D.E"))
p=A.rm(a,q)
if(p!=null)return p
if(B.hU.J(0,a))throw A.c(A.iW(B.z,a))}if(b.length===1&&B.b.gP(b) instanceof A.v){o=t.w.a(B.b.gP(b)).a
switch(a){case"abs":s=o.a
if(s.a)s=s.n(0)
return new A.v(new A.f(s,o.b))
case"sign":return new A.v(new A.f(A.C(o.a.gE(0)),$.o()))
case"sqrt":s=o.a
n=A.nE(s)
m=A.nE(o.b)
if(s.gE(0)>=0&&n!=null&&m!=null)return new A.v(A.k(n,m))
return l
case"sin":case"tan":case"asin":case"atan":case"sinh":case"tanh":s=o.a.j(0,$.p())
return s===0?$.fm():l
case"cos":case"cosh":s=o.a.j(0,$.p())
return s===0?$.ej():l
case"exp":s=o.a.j(0,$.p())
return s===0?$.ej():l
case"ln":case"log":return o.I(0,$.u())?$.fm():l}}return l},
rm(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=null,a=new A.kd(),a0=a2.length
if(a0===2){if(0>=a0)return A.a(a2,0)
s=a.$1(a2[0])
if(1>=a2.length)return A.a(a2,1)
r=a.$1(a2[1])
switch(a1){case"gcd":if(s==null||r==null)return b
return new A.v(A.k(s.aC(0,r),$.o()))
case"lcm":if(s==null||r==null)return b
a0=$.p()
q=s.j(0,a0)
if(q!==0)a0=r.j(0,a0)===0
else a0=!0
if(a0)return new A.v($.J())
a0=s.i(0,r)
if(a0.a)a0=a0.n(0)
return new A.v(A.k(a0.au(0,s.aC(0,r)),$.o()))
case"mod":a0=!0
if(s!=null)if(r!=null)a0=r.j(0,$.p())===0
if(a0)return b
return new A.v(A.k(s.cF(0,r),$.o()))
case"min":a0=a2.length
if(0>=a0)return A.a(a2,0)
q=a2[0]
if(1>=a0)return A.a(a2,1)
q=A.nN(q,a2[1])
a0=a2.length
if(q){if(0>=a0)return A.a(a2,0)
a0=a2[0]}else{if(1>=a0)return A.a(a2,1)
a0=a2[1]}return new A.v(a0)
case"max":a0=a2.length
if(0>=a0)return A.a(a2,0)
q=a2[0]
if(1>=a0)return A.a(a2,1)
q=A.nN(q,a2[1])
a0=a2.length
if(q){if(1>=a0)return A.a(a2,1)
a0=a2[1]}else{if(0>=a0)return A.a(a2,0)
a0=a2[0]}return new A.v(a0)}return b}if(a0!==1){a0=a1==="min"
if(a0||a1==="max"){p=B.b.gP(a2)
for(q=a2.length,o=0;o<a2.length;a2.length===q||(0,A.M)(a2),++o){n=a2[o]
m=n.a
l=p.b
k=p.a
j=n.b
if(a0?m.i(0,l).j(0,k.i(0,j))<0:k.i(0,j).j(0,m.i(0,l))<0)p=n}return new A.v(p)}return b}n=B.b.gP(a2)
switch(a1){case"abs":a0=n.a
if(a0.a)a0=a0.n(0)
return new A.v(new A.f(a0,n.b))
case"sign":return new A.v(new A.f(A.C(n.a.gE(0)),$.o()))
case"floor":return new A.v(A.k(A.ka(n.a,n.b),$.o()))
case"ceiling":case"ceil":return new A.v(A.k(A.ka(n.a.n(0),n.b).n(0),$.o()))
case"round":a0=n.a
q=$.bO()
i=a0.i(0,q)
m=n.b
h=m.i(0,q)
g=a0.gE(0)<0?A.ka(i.n(0).A(0,m),h).n(0):A.ka(i.A(0,m),h)
return new A.v(A.k(g,$.o()))
case"factorial":f=a.$1(n)
if(f==null||f.j(0,$.p())<0||f.j(0,A.C(2000))>0)return b
e=$.o()
for(d=$.bO(),c=e;d.j(0,f)<=0;d=d.A(0,e))c=c.i(0,d)
return new A.v(A.k(c,e))
case"log2":return A.nD(n,$.bO())
case"log10":return A.nD(n,A.C(10))}return b},
nN(a,b){return a.a.i(0,b.b).j(0,b.a.i(0,a.b))<0},
ka(a,b){var s=a.au(0,b),r=a.cF(0,b).j(0,$.p())
return r!==0&&a.gE(0)*b.gE(0)<0?s.G(0,$.o()):s},
nD(a,b){var s,r,q,p,o=null,n=a.a,m=n.j(0,$.p())
if(m===0||n.gE(0)<0)return o
m=new A.k9(b)
s=a.b
r=$.o()
q=s.j(0,r)
if(q===0){p=m.$1(n)
return p==null?o:new A.v(A.k(p,r))}n=n.j(0,r)
if(n===0){p=m.$1(s)
return p==null?o:new A.v(A.k(p.n(0),r))}return o},
nE(a){var s,r,q,p,o
if(a.j(0,$.p())<0)return null
s=$.o()
if(a.j(0,s)<=0)return a
for(r=a,q=s;q.j(0,r)<=0;){p=q.A(0,r).ak(0,1)
o=p.i(0,p)
if(o.I(0,a))return p
if(o.j(0,a)<0)q=p.A(0,s)
else r=p.G(0,s)}return null},
nB(a){if(a instanceof A.v)return 2
if(a instanceof A.aE)return 1
return 0},
nO(a){var s=A.X(t.N,t.p)
return new A.kw(s).$1(a)?s:null},
rf(a,b){var s,r,q,p,o,n,m,l,k,j=t.i
j.a(a)
j.a(b)
s=B.c.j(A.nB(a),A.nB(b))
if(s!==0)return s
r=B.c.j(b.gaa(),a.gaa())
if(r!==0)return r
q=A.nO(a)
p=A.nO(b)
if(q!=null&&p!=null){j=A.hn(new A.at(q,A.q(q).h("at<1>")),t.N)
j.aJ(0,new A.at(p,A.q(p).h("at<1>")))
o=A.L(j,A.q(j).c)
B.b.aV(o)
for(j=o.length,n=0;n<o.length;o.length===j||(0,A.M)(o),++n){m=o[n]
l=q.m(0,m)
if(l==null)l=0
k=p.m(0,m)
if(k==null)k=0
if(l!==k)return B.c.j(k,l)}}return B.a.j(a.gab(),b.gab())},
lq(a){var s
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
return s>=48&&s<=57},
mU(a){var s,r
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
if(!(s>=65&&s<=90))r=s>=97&&s<=122||a==="_"
else r=!0
return r},
rO(a){var s,r,q,p,o,n,m=null,l=B.a.ao(a,A.l("[eE]",!0))
if(l>=0){s=B.a.F(a,0,l)
r=A.bk(B.a.M(a,l+1),m)
if(r==null)return m
q=r}else{s=a
q=0}p=B.a.ao(s,".")
if(p>=0){q-=s.length-p-1
o=B.a.F(s,0,p)+B.a.M(s,p+1)}else o=s
if(o.length===0)return m
n=A.jh(o,m)
if(n==null)return m
if(q>=0)return A.k(n.i(0,A.C(10).a1(q)),$.o())
return A.k(n,A.C(10).a1(-q))},
bN(a){var s,r,q
t.i.a(a)
if(a instanceof A.v){s=a.a
r=s.b
q=r.j(0,$.o())
s=s.a
return q===0?s.k(0):s.k(0)+"/"+r.k(0)}if(a instanceof A.an)return a.a
if(a instanceof A.aE){s=a.b
r=A.H(s)
return a.a+"("+new A.t(s,r.h("i(1)").a(A.tX()),r.h("t<1,i>")).H(0,", ")+")"}if(a instanceof A.a7)return A.rT(a)
if(a instanceof A.a_)return A.rS(a)
if(a instanceof A.ay)return A.rR(a)
return"Instance of '"+A.dy(a)+"'"},
k8(a){var s,r
if(a instanceof A.ay)return"("+A.bN(a)+")"
if(a instanceof A.v){s=a.a
r=s.b.j(0,$.o())
s=r!==0||s.a.gE(0)<0}else s=!1
if(s)return"("+A.bN(a)+")"
if(a instanceof A.a_)return"("+A.bN(a)+")"
return A.bN(a)},
rT(a){var s,r,q=a.b
if(q instanceof A.v){s=q.a
r=s.b.j(0,$.o())
s=r===0&&s.a.gE(0)<0}else s=!1
if(s){s=q.a
return"1/"+A.k8(new A.a7(a.a,new A.v(new A.f(s.a.n(0),s.b))).V())}return A.k8(a.a)+"^"+A.k8(q)},
nM(a){var s,r
if(a instanceof A.an)return!0
if(a instanceof A.a7){s=!1
if(a.a instanceof A.an){r=a.b
if(r instanceof A.v)s=r.a.b.j(0,$.o())===0}return s}return!1},
nR(a,b){var s,r,q,p,o,n,m=A.d(a.slice(0),A.H(a))
B.b.aW(m,A.m1())
s=A.d([],t.s)
for(r=m.length,q=0;p=m.length,q<p;m.length===r||(0,A.M)(m),++q)s.push(A.k8(m[q]))
o=!1
if(p===1)if(A.nM(B.b.gP(m))){r=B.b.gP(m)
if(r instanceof A.an)n=r.a
else n=r instanceof A.a7&&r.a instanceof A.an?t.eD.a(r.a).a:null
r=n!=null&&n.length===1
o=r}if(s.length===0)return b.k(0)
r=b.j(0,$.o())
if(r===0)return B.b.H(s,"*")
return o?b.k(0)+B.b.gP(s):b.k(0)+"*"+B.b.H(s,"*")},
rS(a){var s,r,q,p,o,n,m,l,k,j,i=t.h,h=A.d([],i),g=A.d([],i),f=$.u()
for(i=a.a,s=i.length,r=0;r<i.length;i.length===s||(0,A.M)(i),++r){q=i[r]
if(q instanceof A.v){p=q.a
f=A.k(f.a.i(0,p.a),f.b.i(0,p.b))
continue}if(q instanceof A.a7){o=q.b
if(o instanceof A.v){p=o.a
n=p.b.j(0,$.o())
p=n===0&&p.a.gE(0)<0}else p=!1
if(p){p=o.a
B.b.l(g,new A.a7(q.a,new A.v(new A.f(p.a.n(0),p.b))).V())
continue}}B.b.l(h,q)}i=f.a
m=i.gE(0)<0?"-":""
if(i.a)i=i.n(0)
s=f.b
l=A.nR(h,i)
k=A.nR(g,s)
if(k==="1")return m+l
i=g.length
if(i!==0){j=!0
if(i<=1){i=s.j(0,$.o())
if(i===0){i=B.b.gP(g)
i=!(A.nM(i)||i instanceof A.aE)}else i=j
j=i}}else j=!1
i=j?"("+k+")":k
return m+l+"/"+i},
rR(a){var s,r,q,p,o,n,m,l,k,j,i=a.a,h=A.d(i.slice(0),A.H(i))
B.b.aW(h,A.m1())
for(i=h.length,s=t.h,r=0,q="";r<h.length;h.length===i||(0,A.M)(h),++r){p=h[r]
o=A.nV(p)
n=o.a
m=o.b
l=n.a
k=l.gE(0)<0
if(k)if(m==null){if(l.a)l=l.n(0)
l=new A.v(new A.f(l,n.b))
j=l}else{if(l.a)l=l.n(0)
l=new A.a_(A.d([new A.v(new A.f(l,n.b)),m],s)).V()
j=l}else j=p
if(q.length===0){if(k)q+="-"}else q+=k?" - ":" + "
q+=A.bN(j)}return q.charCodeAt(0)==0?q:q},
qo(a){var s=A.qp(a)
if(s==null)return null
return A.bN(s)},
qp(a){var s,r
if(B.a.p(a).length===0)return null
try{s=new A.bW(a).aN().V()
return s}catch(r){if(A.ac(r) instanceof A.bD)return null
else return null}},
lr(a){var s,r,q,p,o,n,m
if(B.a.p(a).length===0)return B.N
r=A.qn(a)
if(r!=null){q=r.a
p=r.b
if(B.a.p(p).length===0)return B.N
o=A.lr(q)
if(o.a!==B.O)return o
return A.lr(p)}try{new A.bW(a).aN().V()
return B.e0}catch(n){m=A.ac(n)
if(m instanceof A.bD){s=m
return new A.cF(s.a,s.b)}else return B.e1}},
qn(a){var s,r,q,p,o,n,m
for(s=a.length,r=0,q=0;q<s;++q){p=a[q]
if(p==="(")++r
if(p===")")--r
if(p!=="="||r!==0)continue
o=q>0?a[q-1]:""
n=q+1
m=n<s?a[n]:""
if(o==="="||o==="<"||o===">"||o==="!")return null
if(m==="=")return null
return new A.R(B.a.F(a,0,q),B.a.M(a,n))}return null},
th(a){switch(a.a.a){case 0:case 1:case 4:return null
case 2:return"Error: unbalanced parenthesis"
case 3:return"Error: unknown function "+A.r(a.b)
case 6:return"Error: wrong number of arguments for "+A.r(a.b)
case 5:return"Error: division by zero"
case 7:return"Error: parse failed"}},
be:function be(a,b){this.a=a
this.b=b},
cF:function cF(a,b){this.a=a
this.b=b},
k7:function k7(){},
E:function E(){},
v:function v(a){this.a=a},
an:function an(a){this.a=a},
ay:function ay(a){this.a=a},
iN:function iN(a){this.a=a},
iM:function iM(){},
iO:function iO(){},
a_:function a_(a){this.a=a},
iT:function iT(a){this.a=a},
iS:function iS(){},
iU:function iU(){},
a7:function a7(a,b){this.a=a
this.b=b},
iV:function iV(a){this.a=a},
aE:function aE(a,b){this.a=a
this.b=b},
iQ:function iQ(){},
iP:function iP(){},
iR:function iR(){},
bD:function bD(a,b){this.a=a
this.b=b},
kb:function kb(){},
kc:function kc(){},
kd:function kd(){},
k9:function k9(a){this.a=a},
kw:function kw(a){this.a=a},
bW:function bW(a){this.a=a
this.b=0},
qw(a,b,c,d){var s,r,q,p,o,n,m,l
if(!a.gaM())return null
s=B.a.p(c)
if(s==="oo"||s==="inf"||s==="infinity"||s==="\\infty")return A.lu(a,b,!0,d)
if(s==="-oo"||s==="-inf"||s==="-infinity")return A.lu(a,b,!1,d)
r=A.qv(a,b,s,d)
if(r!=null)return r
q=A.lw(b)
if(q!=null){p=q.a
o=A.aZ(a,p,d,s)
n=q.b
m=A.aZ(a,n,d,s)
if(o!=null&&m!=null&&A.cS(o)&&A.cS(m)){l=A.qt(n,a,p,s,d)
if(l!=null)return l}}return null},
qv(a,b,c,d){var s,r,q,p,o,n,m=null
try{s=a.aE(b,d,c)
if(J.b1(s,"Error"))return m
r=B.a.p(B.a.aO(B.a.p(a.K(s)),A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0),""))
if(J.b1(r,"Error"))return m
q=J.bv(r).toLowerCase()
if(J.N(q,"nan")||J.N(q,"zoo")||J.aV(q,"inf")||J.aV(q,"oo"))return m
p=A.am(J.bv(r))
if(p!=null&&isFinite(p)){o=J.bv(r)
return new A.ao(o)}o=A.l("\\b"+A.a2(d)+"\\b",!0)
if(!o.b.test(r)){o=J.bv(r)
return new A.ao(o)}return m}catch(n){return m}},
qt(a,b,a0,a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d="Error",c=null
for(s=a,r=a0,q=0;q<8;++q,s=o,r=p){p=b.a7(r,a2)
o=b.a7(s,a2)
if(B.a.v(p,d)||B.a.v(o,d))return c
n=A.aZ(b,p,a2,a1)
m=A.aZ(b,o,a2,a1)
if(n==null||m==null)return c
if(A.cS(m)){if(A.cS(n))continue
return c}l=A.am(n)
k=A.am(m)
if(l!=null&&k!=null&&k!==0){j=l/k
if(isFinite(j))return new A.ao(A.eX(j))
return c}i=b.aE("("+p+")/("+o+")",a2,a1)
if(!B.a.v(i,d)){h=B.a.p(b.K(i))
g=A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0)
f=B.a.p(A.m0(h,g,"",0))
if(!B.a.v(f,d)){h=B.a.p(f)
e=h.toLowerCase()
g=!1
if(e!=="nan")if(e!=="zoo")if(!B.a.J(e,"inf"))if(!B.a.J(e,"oo")){g=A.l("\\b"+A.a2(a2)+"\\b",!0)
g=!g.b.test(f)}if(g)return new A.ao(h)}}}return c},
lu(a,b,c,d){var s,r,q,p,o,n,m,l,k=c?"oo":"-oo"
try{s=a.aE(b,d,k)
if(!J.b1(s,"Error")){r=B.a.p(B.a.aO(B.a.p(a.K(s)),A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0),""))
if(!J.b1(r,"Error")){q=J.bv(r).toLowerCase()
if(J.N(q,"0")||J.N(q,"0.0"))return B.a3
if(J.N(q,"oo")||J.N(q,"inf")||J.N(q,"infinity"))return B.hY
if(J.N(q,"-oo")||J.N(q,"-inf"))return B.hZ
p=!1
if(!J.N(q,"nan"))if(!J.N(q,"zoo")){p=A.l("\\b"+A.a2(d)+"\\b",!0)
p=!p.b.test(r)}if(p){p=J.bv(r)
return new A.ao(p)}}}}catch(o){}n=A.lw(b)
if(n!=null){p=n.a
m=A.qu(n.b,a,p,c,d)
if(m!=null)return m}l=A.qr(a,b,c,d)
if(l!=null)return l
return null},
qu(a,b,c,d,e){var s,r,q,p,o,n,m,l=null,k="Error",j="\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",i=A.ls(b,c,e),h=A.ls(b,a,e)
if(i==null||h==null)return l
if(i<h)return B.a3
if(i>h)return l
for(s=a,r=c,q=0;q<i;++q){r=b.a7(r,e)
s=b.a7(s,e)
if(B.a.v(r,k)||B.a.v(s,k))return l}p=B.a.p(B.a.aO(B.a.p(b.K(r)),A.l(j,!0),""))
o=B.a.p(B.a.aO(B.a.p(b.K(s)),A.l(j,!0),""))
if(B.a.v(p,k)||B.a.v(o,k))return l
n=A.am(B.a.p(p))
m=A.am(B.a.p(o))
if(n!=null&&m!=null&&m!==0)return new A.ao(A.eX(n/m))
return l},
ls(a,b,c){var s,r,q,p,o,n
for(s=b,r=0;r<=20;++r,s=q){A.aZ(a,s,c,"0")
q=a.a7(s,c)
if(B.a.v(q,"Error"))return null
p=A.aZ(a,q,c,"0")
o=A.aZ(a,q,c,"1")
n=A.aZ(a,q,c,"2")
if(p!=null&&o!=null&&n!=null&&A.cS(p)&&A.cS(o)&&A.cS(n))return r}return null},
iX(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f="\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",e=B.a.p(b),d=A.l("\\b"+A.a2(c)+"\\b",!0)
if(!d.b.test(e)){s=B.a.p(B.a.aO(B.a.p(a.K(e)),A.l(f,!0),""))
if(!B.a.v(s,"Error")){r=A.am(B.a.p(s))
if(r!=null)return new A.b9(B.I,0,r)}return B.ib}q=A.lv(e,c)
if(q!=null){p=A.iX(a,q,c)
if(p!=null){d=p.a
if(d===B.t)return new A.b9(B.D,p.b,p.c)
if(d===B.D)return new A.b9(B.ie,p.b,g)}return B.id}o=B.a.p(e)
n=A.l("^(?:log|ln)\\((.+)\\)$",!0).a3(o)
if(n==null)m=g
else{d=n.b
if(1>=d.length)return A.a(d,1)
m=d[1]}if(m!=null){d=A.l("\\b"+A.a2(c)+"\\b",!0)
d=d.b.test(m)}else d=!1
if(d)return B.ic
l=A.ls(a,e,c)
if(l!=null){for(k=e,j=0;j<l;++j){k=a.a7(k,c)
if(B.a.v(k,"Error"))return new A.b9(B.t,l,g)}i=A.am(B.a.p(B.a.p(B.a.aO(B.a.p(a.K(k)),A.l(f,!0),""))))
if(i!=null){for(h=1,j=2;j<=l;++j)h*=j
return new A.b9(B.t,l,i/h)}return new A.b9(B.t,l,g)}return g},
lv(a,b){var s,r,q,p=B.a.p(a),o=A.l("^exp\\((.+)\\)$",!0).a3(p)
if(o!=null){s=o.b
if(1>=s.length)return A.a(s,1)
return s[1]}r=A.l("^[eE]\\^\\((.+)\\)$",!0).a3(p)
if(r!=null){s=r.b
if(1>=s.length)return A.a(s,1)
return s[1]}q=A.l("^[eE]\\^(\\w+)$",!0).a3(p)
if(q!=null){s=q.b
if(1>=s.length)return A.a(s,1)
return s[1]}return null},
qr(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=A.lw(b)
if(f==null)return A.qq(a,b,c,d)
s=f.a
r=f.b
q=A.iX(a,s,d)
p=A.iX(a,r,d)
if(q==null||p==null)return A.lt(r,a,s,c,d)
o=q.a
if(o===B.t&&p.a===B.t){n=q.b
m=p.b
if(n<m)return B.r
if(n>m)return A.qs(q,p,c,n-m)
n=q.c
if(n!=null&&p.c!=null){m=p.c
m.toString
l=n/m
if(isFinite(l))return new A.ao(A.eX(l))}}k=o.a-p.a.a
if(k<0)return B.r
if(k>0)return A.iY(a,b,d,c)
if(o===B.D){n=q.b
m=p.b
if(n!==m){if(n<m)return B.r
return A.iY(a,b,d,c)}n=q.c
if(n!=null&&p.c!=null){m=p.c
m.toString
if(n<m)return B.r
if(n>m)return A.iY(a,b,d,c)
j=A.lv(s,d)
if(j==null)j="0"
i=A.lv(r,d)
if(i==null)i="0"
h=B.a.p(B.a.aO(B.a.p(a.K("("+j+") - ("+i+")")),A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0),""))
if(!B.a.v(h,"Error")){g=A.lu(a,"exp("+h+")",c,d)
if(g!=null)return g}}}if(o===B.a4)return A.lt(r,a,s,c,d)
return A.lt(r,a,s,c,d)},
qq(a,b,c,d){var s,r,q=A.iX(a,b,d)
if(q==null)return null
s=q.a
if(s===B.I){r=q.c
if(r!=null)return new A.ao(A.eX(r))}if(s.a>0)return A.iY(a,b,d,c)
return null},
iY(a,b,c,d){var s,r=A.aZ(a,b,c,d?"10000":"-10000")
if(r!=null){s=A.am(r)
if(s!=null){if(s>0)return B.q
if(s<0)return B.C}}return B.q},
qs(a,b,c,d){var s,r,q=a.c
if(q!=null&&b.c!=null){q=J.aN(q)
s=b.c
s.toString
r=q*J.aN(s)
if(!c&&(B.f.bO(d)&1)===1){if(r>0)return B.C
return B.q}if(r>0)return B.q
return B.C}return B.q},
lt(a6,a7,a8,a9,b0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4="Error",a5=a9?"oo":"-oo"
for(o=a6,n=a8,m=0;m<8;++m,o=k,n=l){l=a7.a7(n,b0)
k=a7.a7(o,b0)
if(B.a.v(l,a4)||B.a.v(k,a4))return null
s="("+l+")/("+k+")"
try{r=a7.aE(s,b0,a5)
if(!J.b1(r,a4)){j=B.a.p(a7.K(r))
i=A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0)
q=B.a.p(A.m0(j,i,"",0))
if(!J.b1(q,a4)){p=J.bv(q).toLowerCase()
if(J.N(p,"0")||J.N(p,"0.0"))return B.r
if(J.N(p,"oo")||J.N(p,"inf")||J.N(p,"infinity"))return B.q
if(J.N(p,"-oo")||J.N(p,"-inf"))return B.C
j=!1
if(!J.N(p,"nan"))if(!J.N(p,"zoo"))if(!J.aV(p,"oo"))if(!J.aV(p,"inf")){j=A.l("\\b"+A.a2(b0)+"\\b",!0)
j=!j.b.test(q)}if(j){j=new A.ao(J.bv(q))
return j}}}}catch(h){}g=a9?"100000":"-100000"
f=A.aZ(a7,l,b0,g)
e=A.aZ(a7,k,b0,g)
if(f!=null&&e!=null){d=A.am(f)
c=A.am(e)
if(d!=null&&c!=null&&Math.abs(c)>1e-15){b=d/c
a=a9?"50000":"-50000"
a0=A.aZ(a7,l,b0,a)
a1=A.aZ(a7,k,b0,a)
if(a0!=null&&a1!=null){a2=A.am(a0)
a3=A.am(a1)
if(a2!=null&&a3!=null&&Math.abs(a3)>1e-15){j=Math.abs(b)
if(Math.abs(b-a2/a3)<0.000001*(j+1)){if(j<1e-10)return B.r
if(isFinite(b))return new A.ao(A.eX(b))}}}}}}return null},
aZ(a,b,c,d){var s,r,q,p
try{s=a.aE(b,c,d)
if(J.b1(s,"Error"))return null
r=B.a.p(B.a.aO(B.a.p(a.K(s)),A.l("\\s*[+-]\\s*-?0(\\.0*)?\\s*\\*?\\s*I$",!0),""))
if(J.b1(r,"Error"))return null
q=J.bv(r)
return q}catch(p){return null}},
cS(a){var s=A.am(a)
if(s!=null)return Math.abs(s)<1e-12
return B.a.p(a)==="0"},
eX(a){var s,r,q
if(Math.abs(a-B.f.b6(a))<1e-9&&Math.abs(a)<1e15)return B.c.k(B.f.bO(a))
s=B.f.bQ(a,10)
if(B.a.J(s,".")){r=A.l("0+$",!0)
r=A.A(s,r,"")
q=A.l("\\.$",!0)
r=A.A(r,q,"")}else r=s
return r},
lw(a){var s,r,q,p,o,n,m,l,k=null,j=B.a.p(a)
for(s=j.length,r=k,q=0,p=0;p<s;++p){o=j[p]
if(o==="("||o==="[")++q
else if(o===")"||o==="]")--q
else if(o==="/"&&q===0){n=p+1
if(n<s&&j[n]==="/")continue
if(r!=null)return k
r=p}}if(r==null)return k
m=B.a.p(B.a.F(j,0,r))
l=B.a.p(B.a.M(j,r+1))
if(m.length===0||l.length===0)return k
return new A.k_(A.mV(m),A.mV(l))},
mV(a){var s,r,q,p,o,n=B.a.p(a)
if(B.a.v(n,"(")&&B.a.T(n,")")){for(s=n.length,r=s-1,q=0,p=0;p<s;++p){o=n[p]
if(o==="(")++q
if(o===")")--q
if(q===0&&p<r)return n}return B.a.p(B.a.F(n,1,r))}return n},
ao:function ao(a){this.a=a},
k_:function k_(a,b){this.a=a
this.b=b},
cp:function cp(a,b){this.a=a
this.b=b},
b9:function b9(a,b,c){this.a=a
this.b=b
this.c=c},
o5(a,b){var s,r,q
if(a.length>512||A.lY(a))return a
if(A.l("[A-Za-z_][A-Za-z_0-9]*",!0).am(0,a).X(0,new A.kM(b)))return a
s=A.bn(a)
r=s==null?null:A.cf(s)
if(r!=null)q=r.a.length-1<=0||r.b===b
else q=!1
return q?r.k(0):a},
lY(a){var s,r=!0
if(!B.a.v(a,"Error")){s=A.l("\\b(nan|zoo|oo|inf|infinity|complexinfinity)\\b",!1)
if(!s.b.test(a)){r=A.l("\\b(?:Derivative|Subs)\\s*\\(",!1)
r=r.b.test(a)}}return r},
tW(a,b,c,d,e,f,g){var s,r,q,p,o,n,m,l,k,j,i,h
if(d<1||d>64)return"Error: order must be in 1..64"
s=new A.kV()
try{r=s.$1(f.$1(a))
q=$.o()
p=A.d([],t.s)
o=0
k="("+e+")"
for(;;){j=o
if(typeof j!=="number")return j.af()
if(!(j<d))break
n=s.$1(g.$3(r,b,k))
m=s.$1(f.$1("("+A.r(n)+")/"+A.r(q)))
J.fo(p,"("+A.r(m)+")*(("+b+")-("+e+"))^"+A.r(o))
j=o
if(typeof j!=="number")return j.A()
if(j+1<d){r=s.$1(c.$2(r,b))
if(J.N(r,"0"))break
j=q
i=o
if(typeof i!=="number")return i.A()
q=J.m6(j,A.C(i+1))}j=o
if(typeof j!=="number")return j.A()
o=j+1}k=A.o5(s.$1(f.$1(J.l0(p,"+"))),b)
return k}catch(h){l=A.ac(h)
k=A.r(l)
return"Error: series failed: "+k}},
kM:function kM(a){this.a=a},
kV:function kV(){},
bn(a){var s=A.cm(a)
if(s==null)return null
return s.k(0)},
qE(a,b){var s=A.cm(a)
if(s==null)return null
if(s.a.length-1>=1&&s.b!==b)return"0"
return s.ah().k(0)},
j4(a,b){var s,r,q,p,o,n,m,l,k=null,j=B.a.ao(a,"=")
if(j>=0){s=A.cm(B.a.F(a,0,j))
r=A.cm(B.a.M(a,j+1))
if(s==null||r==null)return k
q=s.G(0,r)}else q=A.cm(a)
if(q==null)return k
p=q.a
o=p.length
n=o-1
if(n<=0)return o===0?k:A.d([],t.s)
if(q.b!==b)return k
if(n===1){if(1>=o)return A.a(p,1)
m=p[1]
l=p[0]
return A.d([new A.f(l.a.n(0),l.b).ac(0,m).k(0)],t.s)}if(n===2){if(2>=o)return A.a(p,2)
return A.qB(p[2],p[1],p[0])}return k},
qF(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=A.cm(a)
if(g==null)return null
s=g.a
r=s.length
if(r-1>=1&&g.b!==b)return null
if(r===0)return"0"
q=t.G
p=new A.G(A.cb([$.J(),$.u()],q),b)
o=new A.G(B.h,b)
for(n=0;n<r;++n){m=s[n]
l=$.p()
m=m.a.j(0,l)
if(m===0)continue
m=s[n]
k=n+1
j=A.C(k)
i=A.k(m.a.i(0,$.o()),m.b.i(0,j))
m=i.a.j(0,l)
if(m===0)m=new A.G(B.h,b)
else{h=A.bh([i],!1,q)
h.$flags=3
m=new A.G(h,b)}o=o.A(0,m.i(0,p.a1(k)))}return o.k(0)},
qD(a,b,c,d){var s,r,q,p,o,n,m,l,k=A.cm(a)
if(k==null)return null
s=k.a
r=s.length
if(r-1>=1&&k.b!==b)return null
q=A.mZ(c)
p=A.mZ(d)
if(q==null||p==null)return null
o=A.d([$.J()],t.j)
for(n=0;n<r;){m=s[n];++n
l=A.C(n)
B.b.l(o,A.k(m.a.i(0,$.o()),m.b.i(0,l)))}s=new A.j2(o)
return J.oz(s.$1(p),s.$1(q)).k(0)},
mZ(a){var s,r,q,p,o,n=null,m=A.aX(a)
if(m==null)return n
s=A.l("^(-?\\d+)/(\\d+)$",!0).a3(m)
if(s!=null){r=s.b
if(1>=r.length)return A.a(r,1)
q=r[1]
q.toString
q=A.ae(q,n)
if(2>=r.length)return A.a(r,2)
r=r[2]
r.toString
return A.k(q,A.ae(r,n))}p=B.a.v(m,"-")
o=A.nm(p?B.a.M(m,1):m)
if(o==null)return n
return p?new A.f(o.a.n(0),o.b):o},
n_(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=A.cm(a)
if(d==null)return A.pv(a)
s=d.a
r=s.length
if(r===0)return"0"
q=d.b
if(r-1===0){if(0>=r)return A.a(s,0)
return s[0].k(0)}p=A.qA(d)
if(p==null)return null
o=d.gb_()
n=d.aT()
m=A.d([],t.eJ)
for(s=A.f9(p,p.r,A.q(p).c),r=t.G,l=s.$ti.c;s.q();){k=s.d
if(k==null)k=l.a(k)
j=A.bh([$.J(),$.u()],!1,r)
j.$flags=3
i=k.a.j(0,$.p())
if(i===0)i=new A.G(B.h,q)
else{h=A.bh([k],!1,r)
h.$flags=3
i=new A.G(h,q)}g=new A.G(j,q).G(0,i)
f=0
for(;;){if(n.a.length-1>=1)i=A.qx(n,k).a.j(0,$.p())===0
else i=!1
if(!i)break
e=n.Y(g)
if(e.b.a.length!==0)break
n=e.a;++f}if(f>0)B.b.l(m,new A.dZ(f,k))}B.b.aW(m,new A.j3())
return A.qy(o,m,n,q)},
qx(a,b){var s,r,q,p,o,n,m,l,k=$.J()
for(s=a.a,r=s.length-1,q=b.a,p=b.b;r>=0;--r){o=A.k(k.a.i(0,q),k.b.i(0,p))
n=s[r]
m=n.b
l=o.b
k=A.k(o.a.i(0,m).A(0,n.a.i(0,l)),l.i(0,m))}return k},
qA(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=A.qz(a),e=B.b.gR(f)
if(e.a)e=e.n(0)
s=B.b.bn(f,new A.j0())
if(!(s>=0&&s<f.length))return A.a(f,s)
r=f[s]
q=A.mX(r.a?r.n(0):r)
p=A.mX(e)
if(q==null||p==null)return null
o=A.cK(t.G)
if(s>0)o.l(0,$.J())
for(n=A.f9(q,q.r,A.q(q).c),m=A.q(p),l=m.h("ba<1>"),m=m.c,k=n.$ti.c;n.q();){j=n.d
if(j==null)j=k.a(j)
for(i=new A.ba(p,p.r,l),i.c=p.e;i.q();){h=i.d
g=A.k(j,h==null?m.a(h):h)
o.l(0,g)
o.l(0,new A.f(g.a.n(0),g.b))}}return o},
qz(a){var s,r,q,p,o,n,m=$.o()
for(s=a.a,r=s.length,q=0;q<r;++q){p=s[q].b
o=p.j(0,$.p())
o=o===0?m:A.mY(p,m.W(0,p))
if(o.c===0)A.x(B.e)
m=m.a2(o).i(0,p)}p=A.d([],t.W)
for(q=0;q<r;++q){n=s[q]
o=n.b
if(o.c===0)A.x(B.e)
p.push(n.a.i(0,m.a2(o)))}return p},
mX(a){var s,r,q,p,o=$.p()
if(a.j(0,o)<=0)return A.ms([$.o()],t.Z)
if(a.j(0,A.C(1e12))>0)return null
s=A.cK(t.Z)
r=$.o()
for(q=r;q.i(0,q).j(0,a)<=0;){p=a.W(0,q).j(0,o)
if(p===0){s.l(0,q)
if(q.c===0)A.x(B.e)
s.l(0,a.a2(q))}q=q.A(0,r)}return s},
mY(a,b){var s=$.p(),r=b.j(0,s)
if(r===0)s=a
else{r=a.W(0,b)
s=r.j(0,s)
s=s===0?b:A.mY(r,b.W(0,r))}return s},
qy(a,b,c,d){var s,r,q,p,o,n=A.d([],t.s),m=new A.j_(d)
for(s=b.length,r=0;q=b.length,r<q;b.length===s||(0,A.M)(b),++r){p=b[r]
o=m.$1(p.b)
q=p.a
B.b.l(n,q>1?o+"^"+q:o)}if(c.a.length-1>=1)B.b.l(n,q===0&&a.I(0,$.u())?c.k(0):"("+c.k(0)+")")
if(n.length===0)return a.k(0)
if(a.I(0,$.u()))return B.b.H(n,"*")
if(a.I(0,new A.f(A.C(-1),$.o())))return"-"+B.b.H(n,"*")
return a.k(0)+"*"+B.b.H(n,"*")},
qB(a,b,c){var s,r,q,p,o,n,m=b.i(0,b),l=A.C(4),k=$.o(),j=m.G(0,new A.f(l,k).i(0,a).i(0,c)),i=new A.f(A.C(2),k).i(0,a),h=new A.f(b.a.n(0),b.b).ac(0,i)
m=j.a
l=m.j(0,$.p())
if(l===0)return A.d([h.k(0)],t.s)
s=j.b
r=A.qC((m.a?m.n(0):m).i(0,s))
q=r.b
p=A.k(r.a,s).ac(0,i)
o=m.gE(0)<0
m=q.j(0,k)
if(m===0){if(!o)return A.d([h.A(0,p).k(0),h.G(0,p).k(0)],t.s)
return A.d([A.j1(h,p,"I"),A.j1(h,new A.f(p.a.n(0),p.b),"I")],t.s)}n=o?"sqrt("+q.k(0)+")*I":"sqrt("+q.k(0)+")"
return A.d([A.j1(h,p,n),A.j1(h,new A.f(p.a.n(0),p.b),n)],t.s)},
j1(a,b,c){var s,r,q,p=$.p(),o=a.a.j(0,p),n=o!==0
o=n?a.k(0):""
s=b.a
p=s.j(0,p)
if(p===0)return n?o.charCodeAt(0)==0?o:o:"0"
r=s.gE(0)<0
p=s.a?s.n(0):s
q=new A.f(p,b.b)
if(n)p=o+(r?" - ":" + ")
else p=r?o+"-":o
p=(!q.I(0,$.u())?p+q.k(0)+"*":p)+c
return p.charCodeAt(0)==0?p:p},
qC(a){var s,r,q,p,o,n=$.o()
if(a.j(0,n)<=0)return new A.R(n,a)
s=$.bO()
for(r=a;s.i(0,s).j(0,r)<=0;){q=s.c===0
p=0
for(;;){o=r.W(0,s).j(0,$.p())
if(!(o===0))break
if(q)A.x(B.e)
r=r.a2(s);++p}if(p>0){n=n.i(0,s.a1(B.c.S(p,2)))
if((p&1)===1)r=r.i(0,s)}s=s.A(0,$.o())}return new A.R(n,r)},
cm(a){var s,r,q,p,o=A.A(a,"**","^"),n=A.A(o," ","")
if(J.S(n)===0||J.aV(n,"="))return null
try{s=new A.jZ(n)
r=s.cB()
o=s
if(o.b<o.a.length)return null
o=r.a
q=s.c
o=A.bj(o,q==null?"x":q)
return o}catch(p){if(A.ac(p) instanceof A.aq)return null
else throw p}},
nm(a){var s,r,q,p,o=A.l("^\\d+$",!0)
if(o.b.test(a))return A.k(A.ae(a,null),$.o())
s=A.l("^(\\d*)\\.(\\d+)$",!0).a3(a)
if(s!=null){o=s.b
r=o.length
if(1>=r)return A.a(o,1)
q=o[1]
if(q.length===0)p="0"
else{q=q
q.toString
p=q}if(2>=r)return A.a(o,2)
o=o[2]
o.toString
return A.k(A.ae(p+o,null),A.C(10).a1(o.length))}return null},
nl(a){var s
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
return s>=48&&s<=57},
lM(a){var s,r
if(0>=a.length)return A.a(a,0)
s=a.charCodeAt(0)
if(!(s>=65&&s<=90))r=s>=97&&s<=122
else r=!0
return r},
j2:function j2(a){this.a=a},
j3:function j3(){},
j0:function j0(){},
j_:function j_(a){this.a=a},
aq:function aq(){},
jZ:function jZ(a){var _=this
_.a=a
_.b=0
_.c=null
_.d=0},
o9(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=null,f=b.a
if(B.a.v(f,"details:")){f=B.a.M(f,8)
r=b.b
a.a=null
q=A.o9(a,new A.ew(f,r,b.c,b.d,b.e))
f=f==="simplify"
p=f?B.M:B.y
o=B.a.v(q,"Error")
if(o){n=A.l("requires native|not available|not implemented|no matching rule|unknown engine op",!1)
m=n.b.test(q)}else m=!1
if(m)l=new A.ax(B.hL,p,!1,g)
else if(o)l=g
else{n=a.a
if(n==null){n=f?B.m:B.Z
if(f){k=A.l("\\s+",!0)
k=A.A(q,k,"")
j=A.l("\\s+",!0)
k=k===A.A(r,j,"")}else k=!1
k=new A.ax(n,p,k,g)
n=k}l=n}i=f&&!o?A.pU(r):g
return B.dT.dY(new A.fP(q,i==null||l==null?l:new A.ax(l.a,l.b,l.c,i.b+" \u2260 0 ("+i.a+" \u2260 "+B.b.H(i.c,", ")+")")).b0(),g)}try{switch(f){case"evaluate":f=a.K(b.b)
return f
case"expand":f=a.e1(0,b.b)
return f
case"simplify":f=a.a6(b.b)
return f
case"factor":f=a.cz(b.b)
return f
case"solve":f=b.c
f.toString
f=a.cO(b.b,f)
return f
case"differentiate":f=b.c
f.toString
f=a.a7(b.b,f)
return f
case"integrate":f=b.c
f.toString
f=a.e6(b.b,f,b.d,b.e)
return f
case"limit":f=b.c
f.toString
r=b.d
r.toString
r=a.ee(b.b,f,r)
return r
case"series":f=b.c
f.toString
r=b.d
if(r==null)r="0"
o=b.e
o=A.bk(o==null?"6":o,g)
if(o==null)o=6
r=a.bV(b.b,f,o,r)
return r
case"linsolve":f=t.s
r=t.dG
o=t.dv
n=o.h("D.E")
k=A.L(new A.t(A.d(b.b.split(";"),f),r.a(new A.kP()),o),n)
f=A.L(new A.t(A.d(b.c.split(","),f),r.a(new A.kQ()),o),n)
f=a.cP(k,f)
return f
case"gcd":f=b.c
f.toString
f=a.cK(0,b.b,f)
return f
case"lcm":f=b.c
f.toString
f=a.ed(b.b,f)
return f
case"factorial":f=a.bm(A.eh(b.b,g,g))
return f
case"fibonacci":f=a.e2(A.eh(b.b,g,g))
return f
default:return"Error: unknown engine op "+f}}catch(h){s=A.ac(h)
f=A.r(s)
return"Error: "+f}},
kP:function kP(){},
kQ:function kQ(){},
ew:function ew(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
ty(){var s,r,q,p=new A.eo()
p.bs()
s=v.G.self
r=new A.kI(new A.kJ(p),p)
if(typeof r=="function")A.x(A.aG("Attempting to rewrap a JS function.",null))
q=function(a,b){return function(c){return a(b,c,arguments.length)}}(A.re,r)
q[$.m2()]=r
s.onmessage=q},
kJ:function kJ(a){this.a=a},
kK:function kK(a){this.a=a},
kI:function kI(a,b){this.a=a
this.b=b},
rs(){if($.nH)return
v.G.eval("    window._symCcall0 = function(fn) {\n      return symEngineInstance.ccall(fn, 'string', [], []);\n    };\n    window._symCcall1 = function(fn, a) {\n      return symEngineInstance.ccall(fn, 'string', ['string'], [a]);\n    };\n    window._symCcall2 = function(fn, a, b) {\n      return symEngineInstance.ccall(fn, 'string', ['string','string'], [a, b]);\n    };\n    window._symCcall3 = function(fn, a, b, c) {\n      return symEngineInstance.ccall(fn, 'string', ['string','string','string'], [a, b, c]);\n    };\n    window._symCcallInt = function(fn, a) {\n      return symEngineInstance.ccall(fn, 'string', ['number'], [a]);\n    };\n    window._symCcallIntStr = function(fn, a, b) {\n      return symEngineInstance.ccall(fn, 'string', ['number','string'], [a, b]);\n    };\n    window._symCcallStrInt = function(fn, a, b) {\n      return symEngineInstance.ccall(fn, 'string', ['string','number'], [a, b]);\n    };\n    window._symCcall3StrInt = function(fn, a, b, c, n) {\n      return symEngineInstance.ccall(\n        fn, 'string', ['string','string','string','number'], [a, b, c, n]);\n    };\n    window._symHasExport = function(name) {\n      return typeof symEngineInstance['_' + name] === 'function';\n    };\n    window._symCcallVoidNum = function(fn, a) {\n      symEngineInstance.ccall(fn, null, ['number'], [a]);\n    };\n    window._symCcallNumSetElem = function(ptr, row, col, value) {\n      return symEngineInstance.ccall(\n        'flutter_symengine_matrix_set_element', 'number',\n        ['number','number','number','string'], [ptr, row, col, value]);\n    };\n    window._symCcallStrGetElem = function(ptr, row, col) {\n      return symEngineInstance.ccall(\n        'flutter_symengine_matrix_get_element', 'string',\n        ['number','number','number'], [ptr, row, col]);\n    };\n    window._symCcallStrFromPtr = function(fn, ptr) {\n      return symEngineInstance.ccall(fn, 'string', ['number'], [ptr]);\n    };\n    window._symCcallPtrFromPtr = function(fn, ptr) {\n      return symEngineInstance.ccall(fn, 'number', ['number'], [ptr]);\n    };\n    window._symCcallPtrFromPtrPtr = function(fn, a, b) {\n      return symEngineInstance.ccall(fn, 'number', ['number','number'], [a, b]);\n    };\n    window._symCcallPtrFromIntInt = function(fn, a, b) {\n      return symEngineInstance.ccall(fn, 'number', ['number','number'], [a, b]);\n    };\n  ")
$.nH=!0},
bL(a,b){var s=A.I(v.G._symCcall1(a,b))
if(B.a.v(s,"Error"))A.x(A.ap(a,s,null))
return s},
ea(a,b,c){var s=A.I(v.G._symCcall2(a,b,c))
if(B.a.v(s,"Error"))A.x(A.ap(a,s,null))
return s},
nz(a,b){var s=A.I(v.G._symCcallInt(a,b))
if(B.a.v(s,"Error"))A.x(A.ap(a,s,null))
return s},
nA(a,b,c){var s=A.I(v.G._symCcallIntStr(a,b,c))
if(B.a.v(s,"Error"))A.x(A.ap(a,s,null))
return s},
cR:function cR(a,b,c){this.a=a
this.b=b
this.c=c},
cl:function cl(){},
ap(a,b,c){return new A.eY(a,b,c)},
lx(a){return new A.iZ("initialize","Library not available: "+a,a)},
eY:function eY(a,b,c){this.a=a
this.b=b
this.c=c},
iZ:function iZ(a,b,c){this.a=a
this.b=b
this.c=c},
tQ(a){return Math.sqrt(A.aK(a))},
tP(a){return Math.sin(A.aK(a))},
te(a){return Math.cos(A.aK(a))},
tY(a){return Math.tan(a)},
t4(a){return Math.acos(a)},
t5(a){return Math.asin(a)},
t9(a){return Math.atan(a)},
tj(a){return Math.exp(A.aK(a))},
tw(a){return Math.log(A.aK(a))},
oV(a,b,c,d){var s,r,q,p,o,n,m=null,l=A.bV(c),k=A.bV(d)
if(l==null||k==null||!isFinite(l)||!isFinite(k))return m
s=A.au(A.A(a,"\xb7","*"))
if(s==null)return m
r=t.N
q=t.V
p=s.K(A.B([b,k],r,q))
o=s.K(A.B([b,l],r,q))
if(p==null||o==null||!isFinite(p)||!isFinite(o))return m
n=p-o
return isFinite(n)?n:m},
tO(a,b,c){var s,r,q,p,o,n,m,l,k,j
if(b===c)return 0
s=c>b?1:-1
r=b<c
q=r?b:c
p=r?c:b
o=(p-q)/200
n=a.$1(q)
m=a.$1(p)
if(!isFinite(n)||!isFinite(m))return null
l=n+m
for(k=1;k<200;++k){j=a.$1(q+k*o)
if(!isFinite(j))return null
l+=((k&1)===0?2:4)*j}return s*l*o/3},
tJ(a,b){var s=a.$1(b-1e-7),r=a.$1(b+1e-7)
if(!isFinite(s)||!isFinite(r))return null
if(Math.abs(s-r)/(1+Math.abs(s))>0.001)return null
return(s+r)/2},
o3(a){var s=a.$1(1e10),r=a.$1(1e12)
if(!isFinite(s)||!isFinite(r))return null
if(Math.abs(s-r)/(1+Math.abs(s))>0.000001)return null
return r},
pV(a,b,c,d){var s=A.ir(a,b),r=A.mE(c),q=A.mE(d)
if(s==null||r==null||q==null)return null
return A.pF(s.b,r,q)},
pW(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h=null,g=A.bV(c),f=A.bV(d)
if(g==null||f==null||!isFinite(g)||!isFinite(f))return h
s=A.ir(a,b)
if(s==null)return h
r=s.b
if(r.a.length-1===0)return A.d([],t.n)
q=A.j4(r.k(0),b)
if(q==null)return h
p=g<f
o=p?g:f
n=p?f:g
m=A.d([],t.n)
for(p=q.length,l=0;l<q.length;q.length===p||(0,A.M)(q),++l){k=q[l]
j=A.l("\\b[Ii]\\b",!0)
if(j.b.test(k))continue
j=A.au(k)
if(j==null)i=h
else i=j.K(B.u)
if(i==null||!isFinite(i))return h
if(i>=o&&i<=n)B.b.l(m,i)}return m},
pX(a,b){var s,r,q,p=A.ir(a,b)
if(p==null||!p.a)return null
s=p.c
r=p.b
q=r.a
if(q.length-1===0)return s.a_($.u().ac(0,B.b.gaD(q))).k(0)
return"("+s.k(0)+")/("+r.k(0)+")"},
ir(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=null,c=!0
if(a.length<=512)if(A.ed(a)){c=A.l("^[A-Za-z_][A-Za-z_0-9]*$",!0)
c=!c.b.test(b)}if(c)return d
s=B.a.p(a)
for(;;){if(!(B.a.v(s,"(")&&B.a.T(s,")")))break
c=s.length
q=c-1
p=0
o=0
for(;;){if(!(o<c)){r=!0
break}n=s[o]
if(n==="(")++p
if(n===")")--p
if(p<0)return d
if(p===0&&o<q){r=!1
break}++o}if(!r||p!==0)break
s=B.a.p(B.a.F(s,1,q))}for(c=s.length,p=0,m=-1,o=0;o<c;++o){q=s[o]
if(q==="(")++p
if(q===")")--p
if(p<0)return d
if((q==="+"||q==="-")&&p===0&&o>0){l=B.a.bS(B.a.F(s,0,o))
q=l.length
if(q!==0){n=q-1
if(!(n>=0))return A.a(l,n)
n=!B.a.J("+-*/^(",l[n])
q=n}else q=!1
if(q)return d}if(s[o]==="/"&&p===0){if(m>=0)return d
m=o}}if(m<0||p!==0)return d
k=A.bn(B.a.F(s,0,m))
j=A.bn(B.a.M(s,m+1))
if(k==null||j==null)return d
i=A.cf(k)
h=A.cf(j)
c=!0
if(i!=null)if(h!=null){q=h.a.length
if(q!==0){n=i.a.length-1
if(n<=16){--q
if(q<=16)if(!(n>0&&i.b!==b))c=q>0&&h.b!==b}}}if(c)return d
g=A.bj(i.a,b)
f=A.bj(h.a,b)
e=A.mF(g,f)
if(e==null)return d
c=g.Y(e)
q=f.Y(e)
return new A.e_(e.a.length-1>0,q.a,c.a)},
ed(a){var s,r,q,p,o,n,m,l,k
for(s=A.l("(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE]([+-]?\\d+))?",!0).am(0,a),s=new A.co(s.a,s.b,s.c),r=t.F;s.q();){q=s.d
p=(q==null?r.a(q):q).b
if(1>=p.length)return A.a(p,1)
o=p[1]
n=A.bk(o==null?"0":o,null)
if(n==null)return!1
if(0>=p.length)return A.a(p,0)
p=p[0]
p.toString
m=B.b.gP(B.a.bW(p,A.l("[eE]",!0)))
l=B.a.ao(m,".")
k=l<0?0:m.length-l-1
if(n>1024||n<-1024||Math.abs(n-k)>1024)return!1}return!0}},B={}
var w=[A,J,B]
var $={}
A.l7.prototype={}
J.eA.prototype={
I(a,b){return a===b},
gU(a){return A.dx(a)},
k(a){return"Instance of '"+A.dy(a)+"'"},
ga4(a){return A.cy(A.lP(this))}}
J.eC.prototype={
k(a){return String(a)},
gU(a){return a?519018:218159},
ga4(a){return A.cy(t.y)},
$iZ:1,
$iw:1}
J.de.prototype={
I(a,b){return null==b},
k(a){return"null"},
gU(a){return 0},
$iZ:1}
J.a4.prototype={$iad:1}
J.bU.prototype={
gU(a){return 0},
k(a){return String(a)}}
J.eO.prototype={}
J.bH.prototype={}
J.by.prototype={
k(a){var s=a[$.og()]
if(s==null)s=a[$.m2()]
if(s==null)return this.cT(a)
return"JavaScript function for "+J.b2(s)},
$ic8:1}
J.cI.prototype={
gU(a){return 0},
k(a){return String(a)}}
J.cJ.prototype={
gU(a){return 0},
k(a){return String(a)}}
J.F.prototype={
bj(a,b){return new A.bx(a,A.H(a).h("@<1>").L(b).h("bx<1,2>"))},
l(a,b){A.H(a).c.a(b)
a.$flags&1&&A.a8(a,29)
a.push(b)},
e5(a,b,c){var s
A.H(a).c.a(c)
a.$flags&1&&A.a8(a,"insert",2)
s=a.length
if(b>s)throw A.c(A.lm(b,null))
a.splice(b,0,c)},
aJ(a,b){var s
A.H(a).h("m<1>").a(b)
a.$flags&1&&A.a8(a,"addAll",2)
if(Array.isArray(b)){this.cW(a,b)
return}for(s=J.bu(b);s.q();)a.push(s.gD())},
cW(a,b){var s,r
t.gn.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.c(A.ag(a))
for(r=0;r<s;++r)a.push(b[r])},
ap(a,b,c){var s=A.H(a)
return new A.t(a,s.L(c).h("1(2)").a(b),s.h("@<1>").L(c).h("t<1,2>"))},
H(a,b){var s,r=A.aA(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.u(r,s,A.r(a[s]))
return r.join(b)},
N(a,b){return A.eW(a,0,A.ee(b,"count",t.p),A.H(a).c)},
aA(a,b,c,d){var s,r,q
d.a(b)
A.H(a).L(d).h("1(1,2)").a(c)
s=a.length
for(r=b,q=0;q<s;++q){r=c.$2(r,a[q])
if(a.length!==s)throw A.c(A.ag(a))}return r},
a0(a,b){if(!(b>=0&&b<a.length))return A.a(a,b)
return a[b]},
bq(a,b,c){var s=a.length
if(b>s)throw A.c(A.aw(b,0,s,"start",null))
if(c==null)c=s
else if(c<b||c>s)throw A.c(A.aw(c,b,s,"end",null))
if(b===c)return A.d([],A.H(a))
return A.d(a.slice(b,c),A.H(a))},
cR(a,b){return this.bq(a,b,null)},
gP(a){if(a.length>0)return a[0]
throw A.c(A.aY())},
gR(a){var s=a.length
if(s>0)return a[s-1]
throw A.c(A.aY())},
gaD(a){var s=a.length
if(s===1){if(0>=s)return A.a(a,0)
return a[0]}if(s===0)throw A.c(A.aY())
throw A.c(A.mk())},
X(a,b){var s,r
A.H(a).h("w(1)").a(b)
s=a.length
for(r=0;r<s;++r){if(b.$1(a[r]))return!0
if(a.length!==s)throw A.c(A.ag(a))}return!1},
az(a,b){var s,r
A.H(a).h("w(1)").a(b)
s=a.length
for(r=0;r<s;++r){if(!b.$1(a[r]))return!1
if(a.length!==s)throw A.c(A.ag(a))}return!0},
aW(a,b){var s,r,q,p,o,n=A.H(a)
n.h("e(1,1)?").a(b)
a.$flags&2&&A.a8(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.ry()
if(s===2){r=a[0]
q=a[1]
n=b.$2(r,q)
if(typeof n!=="number")return n.cM()
if(n>0){a[0]=q
a[1]=r}return}p=0
if(n.c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.d2(b,2))
if(p>0)this.dz(a,p)},
aV(a){return this.aW(a,null)},
dz(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
ao(a,b){var s,r=a.length
if(0>=r)return-1
for(s=0;s<r;++s){if(!(s<a.length))return A.a(a,s)
if(J.N(a[s],b))return s}return-1},
J(a,b){var s
for(s=0;s<a.length;++s)if(J.N(a[s],b))return!0
return!1},
gO(a){return a.length===0},
gZ(a){return a.length!==0},
k(a){return A.l5(a,"[","]")},
gC(a){return new J.d8(a,a.length,A.H(a).h("d8<1>"))},
gU(a){return A.dx(a)},
gB(a){return a.length},
m(a,b){if(!(b>=0&&b<a.length))throw A.c(A.kA(a,b))
return a[b]},
u(a,b,c){A.H(a).c.a(c)
a.$flags&2&&A.a8(a)
if(!(b>=0&&b<a.length))throw A.c(A.kA(a,b))
a[b]=c},
bn(a,b){var s
A.H(a).h("w(1)").a(b)
if(0>=a.length)return-1
for(s=0;s<a.length;++s)if(b.$1(a[s]))return s
return-1},
sR(a,b){var s,r
A.H(a).c.a(b)
s=a.length
if(s===0)throw A.c(A.aY())
r=s-1
a.$flags&2&&A.a8(a)
if(!(r>=0))return A.a(a,r)
a[r]=b},
$iy:1,
$im:1,
$in:1}
J.eB.prototype={
ep(a){var s,r,q
if(!Array.isArray(a))return null
s=a.$flags|0
if((s&4)!==0)r="const, "
else if((s&2)!==0)r="unmodifiable, "
else r=(s&1)!==0?"fixed, ":""
q="Instance of '"+A.dy(a)+"'"
if(r==="")return q
return q+" ("+r+"length: "+a.length+")"}}
J.hd.prototype={}
J.d8.prototype={
gD(){var s=this.d
return s==null?this.$ti.c.a(s):s},
q(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.M(q)
throw A.c(q)}s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0},
$iV:1}
J.c9.prototype={
j(a,b){var s
A.aK(b)
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gb5(b)
if(this.gb5(a)===s)return 0
if(this.gb5(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gb5(a){return a===0?1/a<0:a<0},
gE(a){var s
if(a>0)s=1
else s=a<0?-1:a
return s},
ai(a){var s
if(a>=-2147483648&&a<=2147483647)return a|0
if(isFinite(a)){s=a<0?Math.ceil(a):Math.floor(a)
return s+0}throw A.c(A.cT(""+a+".toInt()"))},
cv(a){var s,r
if(a>=0){if(a<=2147483647){s=a|0
return a===s?s:s+1}}else if(a>=-2147483648)return a|0
r=Math.ceil(a)
if(isFinite(r))return r
throw A.c(A.cT(""+a+".ceil()"))},
bO(a){if(a>0){if(a!==1/0)return Math.round(a)}else if(a>-1/0)return 0-Math.round(0-a)
throw A.c(A.cT(""+a+".round()"))},
b6(a){if(a<0)return-Math.round(-a)
else return Math.round(a)},
dV(a,b,c){if(B.c.j(b,c)>0)throw A.c(A.fl(b))
if(this.j(a,b)<0)return b
if(this.j(a,c)>0)return c
return a},
cG(a,b){var s
if(b>20)throw A.c(A.aw(b,0,20,"fractionDigits",null))
s=a.toFixed(b)
if(a===0&&this.gb5(a))return"-"+s
return s},
bQ(a,b){var s
if(b<1||b>21)throw A.c(A.aw(b,1,21,"precision",null))
s=a.toPrecision(b)
if(a===0&&this.gb5(a))return"-"+s
return s},
k(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gU(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
n(a){return-a},
A(a,b){return a+b},
W(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
if(b<0)return s-b
else return s+b},
au(a,b){if((a|0)===a)if(b>=1||b<-1)return a/b|0
return this.cp(a,b)},
S(a,b){return(a|0)===a?a/b|0:this.cp(a,b)},
cp(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.c(A.cT("Result of truncating division is "+A.r(s)+": "+A.r(a)+" ~/ "+b))},
aj(a,b){if(b<0)throw A.c(A.fl(b))
return b>31?0:a<<b>>>0},
ak(a,b){var s
if(b<0)throw A.c(A.fl(b))
if(a>0)s=this.bF(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
aI(a,b){var s
if(a>0)s=this.bF(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
bG(a,b){if(0>b)throw A.c(A.fl(b))
return this.bF(a,b)},
bF(a,b){return b>31?0:a>>>b},
ga4(a){return A.cy(t.o)},
$iaH:1,
$ih:1,
$ias:1}
J.cH.prototype={
dO(a){return Math.abs(a)},
gE(a){var s
if(a>0)s=1
else s=a<0?-1:a
return s},
n(a){return-a},
gt(a){var s,r=a<0?-a-1:a,q=r
for(s=32;q>=4294967296;){q=this.S(q,4294967296)
s+=32}return s-Math.clz32(q)},
ga4(a){return A.cy(t.p)},
$iZ:1,
$ie:1}
J.df.prototype={
ga4(a){return A.cy(t.V)},
$iZ:1}
J.bT.prototype={
bK(a,b,c){var s=b.length
if(c>s)throw A.c(A.aw(c,0,s,null,null))
return new A.fd(b,a,c)},
am(a,b){return this.bK(a,b,0)},
bN(a,b,c){var s,r,q,p,o=null
if(c<0||c>b.length)throw A.c(A.aw(c,0,b.length,o,o))
s=a.length
r=b.length
if(c+s>r)return o
for(q=0;q<s;++q){p=c+q
if(!(p>=0&&p<r))return A.a(b,p)
if(b.charCodeAt(p)!==a.charCodeAt(q))return o}return new A.dE(c,a)},
T(a,b){var s=b.length,r=a.length
if(s>r)return!1
return b===this.M(a,r-s)},
aO(a,b,c){A.pT(0,0,a.length,"startIndex")
return A.m0(a,b,c,0)},
bW(a,b){var s
if(typeof b=="string")return A.d(a.split(b),t.s)
else{if(b instanceof A.ca){s=b.e
s=!(s==null?b.e=b.d3():s)}else s=!1
if(s)return A.d(a.split(b.b),t.s)
else return this.d6(a,b)}},
d6(a,b){var s,r,q,p,o,n,m=A.d([],t.s)
for(s=J.m8(b,a),s=s.gC(s),r=0,q=1;s.q();){p=s.gD()
o=p.gbp()
n=p.gaK()
q=n-o
if(q===0&&r===o)continue
B.b.l(m,this.F(a,r,o))
r=n}if(r<a.length||q>0)B.b.l(m,this.M(a,r))
return m},
bX(a,b,c){var s
if(c<0||c>a.length)throw A.c(A.aw(c,0,a.length,null,null))
s=c+b.length
if(s>a.length)return!1
return b===a.substring(c,s)},
v(a,b){return this.bX(a,b,0)},
F(a,b,c){return a.substring(b,A.pS(b,c,a.length))},
M(a,b){return this.F(a,b,null)},
p(a){var s,r,q,p=a.trim(),o=p.length
if(o===0)return p
if(0>=o)return A.a(p,0)
if(p.charCodeAt(0)===133){s=J.mn(p,1)
if(s===o)return""}else s=0
r=o-1
if(!(r>=0))return A.a(p,r)
q=p.charCodeAt(r)===133?J.mo(p,r):o
if(s===0&&q===o)return p
return p.substring(s,q)},
cH(a){var s=a.trimStart(),r=s.length
if(r===0)return s
if(0>=r)return A.a(s,0)
if(s.charCodeAt(0)!==133)return s
return s.substring(J.mn(s,1))},
bS(a){var s,r=a.trimEnd(),q=r.length
if(q===0)return r
s=q-1
if(!(s>=0))return A.a(r,s)
if(r.charCodeAt(s)!==133)return r
return r.substring(0,J.mo(r,s))},
ao(a,b){var s,r,q,p=a.length
if(typeof b=="string")return a.indexOf(b,0)
if(b instanceof A.ca){s=b.bx(a,0)
return s==null?-1:s.b.index}for(r=J.ef(b),q=0;q<=p;++q)if(r.bN(b,a,q)!=null)return q
return-1},
ec(a,b){var s=a.length,r=b.length
if(s+r>s)s-=r
return a.lastIndexOf(b,s)},
J(a,b){return A.tR(a,b,0)},
j(a,b){var s
A.I(b)
if(a===b)s=0
else s=a<b?-1:1
return s},
k(a){return a},
gU(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
ga4(a){return A.cy(t.N)},
gB(a){return a.length},
$iZ:1,
$iaH:1,
$ihY:1,
$ii:1}
A.bY.prototype={
gC(a){return new A.d9(J.bu(this.gaq()),A.q(this).h("d9<1,2>"))},
gB(a){return J.S(this.gaq())},
gO(a){return J.oD(this.gaq())},
gZ(a){return J.oE(this.gaq())},
N(a,b){var s=A.q(this)
return A.fJ(J.oH(this.gaq(),b),s.c,s.y[1])},
a0(a,b){return A.q(this).y[1].a(J.kZ(this.gaq(),b))},
gR(a){return A.q(this).y[1].a(J.l_(this.gaq()))},
J(a,b){return J.aV(this.gaq(),b)},
k(a){return J.b2(this.gaq())}}
A.d9.prototype={
q(){return this.a.q()},
gD(){return this.$ti.y[1].a(this.a.gD())},
$iV:1}
A.c3.prototype={
gaq(){return this.a}}
A.dN.prototype={$iy:1}
A.dM.prototype={
m(a,b){return this.$ti.y[1].a(J.aL(this.a,b))},
$iy:1,
$in:1}
A.bx.prototype={
bj(a,b){return new A.bx(this.a,this.$ti.h("@<1>").L(b).h("bx<1,2>"))},
gaq(){return this.a}}
A.c4.prototype={
bk(a,b,c){return new A.c4(this.a,this.$ti.h("@<1,2>").L(b).L(c).h("c4<1,2,3,4>"))},
m(a,b){return this.$ti.h("4?").a(this.a.m(0,b))},
ad(a,b){return this.$ti.h("4?").a(this.a.ad(0,b))},
aL(a,b){this.a.aL(0,new A.fL(this,this.$ti.h("~(3,4)").a(b)))},
ga9(){var s=this.$ti
return A.fJ(this.a.ga9(),s.c,s.y[2])},
gaU(){var s=this.$ti
return A.fJ(this.a.gaU(),s.y[1],s.y[3])},
gB(a){var s=this.a
return s.gB(s)},
gO(a){var s=this.a
return s.gO(s)},
gZ(a){var s=this.a
return s.gZ(s)},
gaw(){var s=this.a.gaw(),r=this.$ti.h("a0<3,4>"),q=A.q(s)
return A.dl(s,q.L(r).h("1(m.E)").a(new A.fK(this)),q.h("m.E"),r)}}
A.fL.prototype={
$2(a,b){var s=this.a.$ti
s.c.a(a)
s.y[1].a(b)
this.b.$2(s.y[2].a(a),s.y[3].a(b))},
$S(){return this.a.$ti.h("~(1,2)")}}
A.fK.prototype={
$1(a){var s=this.a.$ti
s.h("a0<1,2>").a(a)
return new A.a0(s.y[2].a(a.a),s.y[3].a(a.b),s.h("a0<3,4>"))},
$S(){return this.a.$ti.h("a0<3,4>(a0<1,2>)")}}
A.di.prototype={
k(a){return"LateInitializationError: "+this.a}}
A.iC.prototype={}
A.y.prototype={}
A.D.prototype={
gC(a){var s=this
return new A.b6(s,s.gB(s),A.q(s).h("b6<D.E>"))},
gO(a){return this.gB(this)===0},
gR(a){var s=this
if(s.gB(s)===0)throw A.c(A.aY())
return s.a0(0,s.gB(s)-1)},
J(a,b){var s,r=this,q=r.gB(r)
for(s=0;s<q;++s){if(J.N(r.a0(0,s),b))return!0
if(q!==r.gB(r))throw A.c(A.ag(r))}return!1},
az(a,b){var s,r,q=this
A.q(q).h("w(D.E)").a(b)
s=q.gB(q)
for(r=0;r<s;++r){if(!b.$1(q.a0(0,r)))return!1
if(s!==q.gB(q))throw A.c(A.ag(q))}return!0},
X(a,b){var s,r,q=this
A.q(q).h("w(D.E)").a(b)
s=q.gB(q)
for(r=0;r<s;++r){if(b.$1(q.a0(0,r)))return!0
if(s!==q.gB(q))throw A.c(A.ag(q))}return!1},
H(a,b){var s,r,q,p=this,o=p.gB(p)
if(b.length!==0){if(o===0)return""
s=A.r(p.a0(0,0))
if(o!==p.gB(p))throw A.c(A.ag(p))
for(r=s,q=1;q<o;++q){r=r+b+A.r(p.a0(0,q))
if(o!==p.gB(p))throw A.c(A.ag(p))}return r.charCodeAt(0)==0?r:r}else{for(q=0,r="";q<o;++q){r+=A.r(p.a0(0,q))
if(o!==p.gB(p))throw A.c(A.ag(p))}return r.charCodeAt(0)==0?r:r}},
eb(a){return this.H(0,"")},
ap(a,b,c){var s=A.q(this)
return new A.t(this,s.L(c).h("1(D.E)").a(b),s.h("@<D.E>").L(c).h("t<1,2>"))},
N(a,b){return A.eW(this,0,A.ee(b,"count",t.p),A.q(this).h("D.E"))}}
A.dF.prototype={
gda(){var s=J.S(this.a),r=this.c
if(r==null||r>s)return s
return r},
gdE(){var s=J.S(this.a),r=this.b
if(r>s)return s
return r},
gB(a){var s,r=J.S(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
return s-q},
a0(a,b){var s=this,r=s.gdE()+b
if(b<0||r>=s.gda())throw A.c(A.h9(b,s.gB(0),s,"index"))
return J.kZ(s.a,r)},
N(a,b){var s,r,q,p=this
A.eQ(b,"count")
s=p.c
r=p.b
if(s==null)return A.eW(p.a,r,B.c.A(r,b),p.$ti.c)
else{q=B.c.A(r,b)
if(s<q)return p
return A.eW(p.a,r,q,p.$ti.c)}}}
A.b6.prototype={
gD(){var s=this.d
return s==null?this.$ti.c.a(s):s},
q(){var s,r=this,q=r.a,p=J.aj(q),o=p.gB(q)
if(r.b!==o)throw A.c(A.ag(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.a0(q,s);++r.c
return!0},
$iV:1}
A.bz.prototype={
gC(a){var s=this.a
return new A.dm(s.gC(s),this.b,A.q(this).h("dm<1,2>"))},
gB(a){var s=this.a
return s.gB(s)},
gO(a){var s=this.a
return s.gO(s)},
gR(a){var s=this.a
return this.b.$1(s.gR(s))},
a0(a,b){var s=this.a
return this.b.$1(s.a0(s,b))}}
A.c6.prototype={$iy:1}
A.dm.prototype={
q(){var s=this,r=s.b
if(r.q()){s.a=s.c.$1(r.gD())
return!0}s.a=null
return!1},
gD(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
$iV:1}
A.t.prototype={
gB(a){return J.S(this.a)},
a0(a,b){return this.b.$1(J.kZ(this.a,b))}}
A.cn.prototype={
gC(a){return new A.dI(J.bu(this.a),this.b,this.$ti.h("dI<1>"))},
ap(a,b,c){var s=this.$ti
return new A.bz(this,s.L(c).h("1(2)").a(b),s.h("@<1>").L(c).h("bz<1,2>"))}}
A.dI.prototype={
q(){var s,r
for(s=this.a,r=this.b;s.q();)if(r.$1(s.gD()))return!0
return!1},
gD(){return this.a.gD()},
$iV:1}
A.c7.prototype={
gC(a){return new A.dc(J.bu(this.a),this.b,B.a5,this.$ti.h("dc<1,2>"))}}
A.dc.prototype={
gD(){var s=this.d
return s==null?this.$ti.y[1].a(s):s},
q(){var s,r,q=this,p=q.c
if(p==null)return!1
for(s=q.a,r=q.b;!p.q();){q.d=null
if(s.q()){q.c=null
p=J.bu(r.$1(s.gD()))
q.c=p}else return!1}q.d=q.c.gD()
return!0},
$iV:1}
A.j6.prototype={
gC(a){var s=this.a
return new A.dG(s.gC(s),this.b,A.q(this).h("dG<1>"))}}
A.dG.prototype={
q(){if(--this.b>=0)return this.a.q()
this.b=-1
return!1},
gD(){if(this.b<0){this.$ti.c.a(null)
return null}return this.a.gD()},
$iV:1}
A.db.prototype={
q(){return!1},
gD(){throw A.c(A.aY())},
$iV:1}
A.aB.prototype={}
A.ci.prototype={
gB(a){return J.S(this.a)},
a0(a,b){var s=this.a,r=J.aj(s)
return r.a0(s,r.gB(s)-1-b)}}
A.e9.prototype={}
A.R.prototype={$r:"+(1,2)",$s:1}
A.dX.prototype={$r:"+condition,expression(1,2)",$s:2}
A.bp.prototype={$r:"+error,value(1,2)",$s:3}
A.dY.prototype={$r:"+inner,outer(1,2)",$s:4}
A.dZ.prototype={$r:"+mult,root(1,2)",$s:5}
A.cY.prototype={$r:"+quotient,remainder(1,2)",$s:6}
A.e_.prototype={$r:"+cancelled,denominator,numerator(1,2,3)",$s:7}
A.cu.prototype={$r:"+kind,x,y(1,2,3)",$s:8}
A.aR.prototype={$r:"+ok,x,y(1,2,3)",$s:9}
A.c0.prototype={$r:"+x1,x2,y1,y2(1,2,3,4)",$s:10}
A.e0.prototype={$r:"+mag,u,v,x,y(1,2,3,4,5)",$s:11}
A.da.prototype={
bk(a,b,c){var s=A.q(this)
return A.mt(this,s.c,s.y[1],b,c)},
gO(a){return this.gB(this)===0},
gZ(a){return this.gB(this)!==0},
k(a){return A.lb(this)},
ad(a,b){A.oS()},
gaw(){return new A.br(this.e_(),A.q(this).h("br<a0<1,2>>"))},
e_(){var s=this
return function(){var r=0,q=1,p=[],o,n,m,l,k
return function $async$gaw(a,b,c){if(b===1){p.push(c)
r=q}for(;;)switch(r){case 0:o=s.ga9(),o=o.gC(o),n=A.q(s),m=n.y[1],n=n.h("a0<1,2>")
case 2:if(!o.q()){r=3
break}l=o.gD()
k=s.m(0,l)
r=4
return a.b=new A.a0(l,k==null?m.a(k):k,n),1
case 4:r=2
break
case 3:return 0
case 1:return a.c=p.at(-1),3}}}},
$iaa:1}
A.bQ.prototype={
gB(a){return this.b.length},
gcc(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
a8(a){if(typeof a!="string")return!1
if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
m(a,b){if(!this.a8(b))return null
return this.b[this.a[b]]},
aL(a,b){var s,r,q,p
this.$ti.h("~(1,2)").a(b)
s=this.gcc()
r=this.b
for(q=s.length,p=0;p<q;++p)b.$2(s[p],r[p])},
ga9(){return new A.cr(this.gcc(),this.$ti.h("cr<1>"))},
gaU(){return new A.cr(this.b,this.$ti.h("cr<2>"))}}
A.cr.prototype={
gB(a){return this.a.length},
gO(a){return 0===this.a.length},
gZ(a){return 0!==this.a.length},
gC(a){var s=this.a
return new A.bI(s,s.length,this.$ti.h("bI<1>"))}}
A.bI.prototype={
gD(){var s=this.d
return s==null?this.$ti.c.a(s):s},
q(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0},
$iV:1}
A.cD.prototype={
l(a,b){A.q(this).c.a(b)
A.oT()}}
A.bR.prototype={
gB(a){return this.b},
gO(a){return this.b===0},
gZ(a){return this.b!==0},
gC(a){var s,r=this,q=r.$keys
if(q==null){q=Object.keys(r.a)
r.$keys=q}s=q
return new A.bI(s,s.length,r.$ti.h("bI<1>"))},
J(a,b){if(typeof b!="string")return!1
if("__proto__"===b)return!1
return this.a.hasOwnProperty(b)}}
A.bS.prototype={
gB(a){return this.a.length},
gO(a){return this.a.length===0},
gZ(a){return this.a.length!==0},
gC(a){var s=this.a
return new A.bI(s,s.length,this.$ti.h("bI<1>"))},
dg(){var s,r,q,p,o=this,n=o.$map
if(n==null){n=new A.dg(o.$ti.h("dg<1,1>"))
for(s=o.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.M)(s),++q){p=s[q]
n.u(0,p,p)}o.$map=n}return n},
J(a,b){return this.dg().a8(b)}}
A.dB.prototype={}
A.j7.prototype={
ar(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.du.prototype={
k(a){return"Null check operator used on a null value"}}
A.eD.prototype={
k(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.f0.prototype={
k(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.hX.prototype={
k(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.e2.prototype={
k(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$icO:1}
A.bP.prototype={
k(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.oa(r==null?"unknown":r)+"'"},
$ic8:1,
gev(){return this},
$C:"$1",
$R:1,
$D:null}
A.ep.prototype={$C:"$0",$R:0}
A.eq.prototype={$C:"$2",$R:2}
A.eZ.prototype={}
A.eS.prototype={
k(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.oa(s)+"'"}}
A.cC.prototype={
I(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.cC))return!1
return this.$_target===b.$_target&&this.a===b.a},
gU(a){return(A.ei(this.a)^A.dx(this.$_target))>>>0},
k(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.dy(this.a)+"'")}}
A.eR.prototype={
k(a){return"RuntimeError: "+this.a}}
A.b4.prototype={
gB(a){return this.a},
gO(a){return this.a===0},
gZ(a){return this.a!==0},
ga9(){return new A.at(this,A.q(this).h("at<1>"))},
gaU(){return new A.dk(this,A.q(this).h("dk<2>"))},
gaw(){return new A.O(this,A.q(this).h("O<1,2>"))},
a8(a){var s,r
if(typeof a=="string"){s=this.b
if(s==null)return!1
return s[a]!=null}else if(typeof a=="number"&&(a&0x3fffffff)===a){r=this.c
if(r==null)return!1
return r[a]!=null}else return this.e7(a)},
e7(a){var s=this.d
if(s==null)return!1
return this.b4(s[this.b3(a)],a)>=0},
m(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.e8(b)},
e8(a){var s,r,q=this.d
if(q==null)return null
s=q[this.b3(a)]
r=this.b4(s,a)
if(r<0)return null
return s[r].b},
u(a,b,c){var s,r,q=this,p=A.q(q)
p.c.a(b)
p.y[1].a(c)
if(typeof b=="string"){s=q.b
q.bY(s==null?q.b=q.bz():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.bY(r==null?q.c=q.bz():r,b,c)}else q.ea(b,c)},
ea(a,b){var s,r,q,p,o=this,n=A.q(o)
n.c.a(a)
n.y[1].a(b)
s=o.d
if(s==null)s=o.d=o.bz()
r=o.b3(a)
q=s[r]
if(q==null)s[r]=[o.bA(a,b)]
else{p=o.b4(q,a)
if(p>=0)q[p].b=b
else q.push(o.bA(a,b))}},
ad(a,b){var s=this
if(typeof b=="string")return s.cn(s.b,b)
else if(typeof b=="number"&&(b&0x3fffffff)===b)return s.cn(s.c,b)
else return s.e9(b)},
e9(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.b3(a)
r=n[s]
q=o.b4(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.cr(p)
if(r.length===0)delete n[s]
return p.b},
aL(a,b){var s,r,q=this
A.q(q).h("~(1,2)").a(b)
s=q.e
r=q.r
while(s!=null){b.$2(s.a,s.b)
if(r!==q.r)throw A.c(A.ag(q))
s=s.c}},
bY(a,b,c){var s,r=A.q(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.bA(b,c)
else s.b=c},
cn(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.cr(s)
delete a[b]
return s.b},
cd(){this.r=this.r+1&1073741823},
bA(a,b){var s=this,r=A.q(s),q=new A.hl(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.cd()
return q},
cr(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.cd()},
b3(a){return J.aM(a)&1073741823},
b4(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.N(a[r].a,b))return r
return-1},
k(a){return A.lb(this)},
bz(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$il9:1}
A.hl.prototype={}
A.at.prototype={
gB(a){return this.a.a},
gO(a){return this.a.a===0},
gC(a){var s=this.a
return new A.aP(s,s.r,s.e,this.$ti.h("aP<1>"))},
J(a,b){return this.a.a8(b)}}
A.aP.prototype={
gD(){return this.d},
q(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.c(A.ag(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}},
$iV:1}
A.dk.prototype={
gB(a){return this.a.a},
gO(a){return this.a.a===0},
gC(a){var s=this.a
return new A.dj(s,s.r,s.e,this.$ti.h("dj<1>"))}}
A.dj.prototype={
gD(){return this.d},
q(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.c(A.ag(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.b
r.c=s.c
return!0}},
$iV:1}
A.O.prototype={
gB(a){return this.a.a},
gO(a){return this.a.a===0},
gC(a){var s=this.a
return new A.b5(s,s.r,s.e,this.$ti.h("b5<1,2>"))}}
A.b5.prototype={
gD(){var s=this.d
s.toString
return s},
q(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.c(A.ag(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=new A.a0(s.a,s.b,r.$ti.h("a0<1,2>"))
r.c=s.c
return!0}},
$iV:1}
A.dg.prototype={
b3(a){return A.tb(a)&1073741823},
b4(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.N(a[r].a,b))return r
return-1}}
A.kD.prototype={
$1(a){return this.a(a)},
$S:31}
A.kE.prototype={
$2(a,b){return this.a(a,b)},
$S:88}
A.kF.prototype={
$1(a){return this.a(A.I(a))},
$S:79}
A.ah.prototype={
k(a){return this.cq(!1)},
cq(a){var s,r,q,p,o,n=this.de(),m=this.bc(),l=(a?"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
if(!(q<m.length))return A.a(m,q)
o=m[q]
l=a?l+A.mI(o):l+A.r(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
de(){var s,r=this.$s
while($.k0.length<=r)B.b.l($.k0,null)
s=$.k0[r]
if(s==null){s=this.d2()
B.b.u($.k0,r,s)}return s},
d2(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=t.K,j=J.bg(l,k)
for(s=0;s<l;++s)j[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
B.b.u(j,q,r[s])}}return A.cb(j,k)}}
A.bb.prototype={
bc(){return[this.a,this.b]},
I(a,b){if(b==null)return!1
return b instanceof A.bb&&this.$s===b.$s&&J.N(this.a,b.a)&&J.N(this.b,b.b)},
gU(a){return A.dv(this.$s,this.a,this.b,B.i)}}
A.c_.prototype={
bc(){return[this.a,this.b,this.c]},
I(a,b){var s=this
if(b==null)return!1
return b instanceof A.c_&&s.$s===b.$s&&J.N(s.a,b.a)&&J.N(s.b,b.b)&&J.N(s.c,b.c)},
gU(a){var s=this
return A.dv(s.$s,s.a,s.b,s.c)}}
A.ct.prototype={
bc(){return this.a},
I(a,b){if(b==null)return!1
return b instanceof A.ct&&this.$s===b.$s&&A.qZ(this.a,b.a)},
gU(a){return A.dv(this.$s,A.pA(this.a),B.i,B.i)}}
A.ca.prototype={
k(a){return"RegExp/"+this.a+"/"+this.b.flags},
gcf(){var s=this,r=s.c
if(r!=null)return r
r=s.b
return s.c=A.l6(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"g")},
gdi(){var s=this,r=s.d
if(r!=null)return r
r=s.b
return s.d=A.l6(s.a,r.multiline,!r.ignoreCase,r.unicode,r.dotAll,"y")},
d3(){var s,r=this.a
if(!B.a.J(r,"("))return!1
s=this.b.unicode?"u":""
return new RegExp("(?:)|"+r,s).exec("").length>1},
a3(a){var s=this.b.exec(a)
if(s==null)return null
return new A.cX(s)},
bK(a,b,c){var s=b.length
if(c>s)throw A.c(A.aw(c,0,s,null,null))
return new A.f2(this,b,c)},
am(a,b){return this.bK(0,b,0)},
bx(a,b){var s,r=this.gcf()
if(r==null)r=A.cv(r)
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.cX(s)},
dc(a,b){var s,r=this.gdi()
if(r==null)r=A.cv(r)
r.lastIndex=b
s=r.exec(a)
if(s==null)return null
return new A.cX(s)},
bN(a,b,c){var s=b.length
if(c>s)throw A.c(A.aw(c,0,s,null,null))
return this.dc(b,c)},
ef(a,b){return this.bN(0,b,0)},
$ihY:1,
$iqf:1}
A.cX.prototype={
gbp(){return this.b.index},
gaK(){var s=this.b
return s.index+s[0].length},
m(a,b){var s=this.b
if(!(b<s.length))return A.a(s,b)
return s[b]},
$ibi:1,
$ibB:1}
A.f2.prototype={
gC(a){return new A.co(this.a,this.b,this.c)}}
A.co.prototype={
gD(){var s=this.d
return s==null?t.F.a(s):s},
q(){var s,r,q,p,o,n,m=this,l=m.b
if(l==null)return!1
s=m.c
r=l.length
if(s<=r){q=m.a
p=q.bx(l,s)
if(p!=null){m.d=p
o=p.gaK()
if(p.b.index===o){s=!1
if(q.b.unicode){q=m.c
n=q+1
if(n<r){if(!(q>=0&&q<r))return A.a(l,q)
q=l.charCodeAt(q)
if(q>=55296&&q<=56319){if(!(n>=0))return A.a(l,n)
s=l.charCodeAt(n)
s=s>=56320&&s<=57343}}}o=(s?o+1:o)+1}m.c=o
return!0}}m.b=m.d=null
return!1},
$iV:1}
A.dE.prototype={
gaK(){return this.a+this.c.length},
m(a,b){if(b!==0)throw A.c(A.lm(b,null))
return this.c},
$ibi:1,
gbp(){return this.a}}
A.fd.prototype={
gC(a){return new A.fe(this.a,this.b,this.c)}}
A.fe.prototype={
q(){var s,r,q=this,p=q.c,o=q.b,n=o.length,m=q.a,l=m.length
if(p+n>l){q.d=null
return!1}s=m.indexOf(o,p)
if(s<0){q.c=l+1
q.d=null
return!1}r=s+n
q.d=new A.dE(s,o)
q.c=r===q.c?r+1:r
return!0},
gD(){var s=this.d
s.toString
return s},
$iV:1}
A.jn.prototype={
al(){var s=this.b
if(s===this)throw A.c(new A.di("Field '"+this.a+"' has not been initialized."))
return s}}
A.cd.prototype={
ga4(a){return B.i_},
dR(a,b,c){var s=new DataView(a,b)
return s},
ct(a){return this.dR(a,0,null)},
$iZ:1,
$icd:1,
$ien:1}
A.dr.prototype={
gcu(a){if(((a.$flags|0)&2)!==0)return new A.fi(a.buffer)
else return a.buffer}}
A.fi.prototype={
ct(a){var s=A.pw(this.a,0,null)
s.$flags=3
return s},
$ien:1}
A.eG.prototype={
ga4(a){return B.i0},
$iZ:1,
$il2:1}
A.cL.prototype={
gB(a){return a.length},
$iaO:1}
A.dp.prototype={
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iy:1,
$im:1,
$in:1}
A.dq.prototype={
u(a,b,c){A.K(c)
a.$flags&2&&A.a8(a)
A.c2(b,a,a.length)
a[b]=c},
$iy:1,
$im:1,
$in:1}
A.eH.prototype={
ga4(a){return B.i1},
$iZ:1,
$ih0:1}
A.eI.prototype={
ga4(a){return B.i2},
$iZ:1,
$ih1:1}
A.eJ.prototype={
ga4(a){return B.i3},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$iha:1}
A.eK.prototype={
ga4(a){return B.i4},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ihb:1}
A.eL.prototype={
ga4(a){return B.i5},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ihc:1}
A.eM.prototype={
ga4(a){return B.i7},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ij9:1}
A.eN.prototype={
ga4(a){return B.i8},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ija:1}
A.ds.prototype={
ga4(a){return B.i9},
gB(a){return a.length},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ijb:1}
A.dt.prototype={
ga4(a){return B.ia},
gB(a){return a.length},
m(a,b){A.c2(b,a,a.length)
return a[b]},
$iZ:1,
$ijc:1}
A.dT.prototype={}
A.dU.prototype={}
A.dV.prototype={}
A.dW.prototype={}
A.b7.prototype={
h(a){return A.e7(v.typeUniverse,this,a)},
L(a){return A.nt(v.typeUniverse,this,a)}}
A.f7.prototype={}
A.fh.prototype={
k(a){return A.aS(this.a,null)}}
A.f6.prototype={
k(a){return this.a}}
A.e3.prototype={$ibF:1}
A.je.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:19}
A.jd.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:78}
A.jf.prototype={
$0(){this.a.$0()},
$S:30}
A.jg.prototype={
$0(){this.a.$0()},
$S:30}
A.k3.prototype={
cU(a,b){if(self.setTimeout!=null)self.setTimeout(A.d2(new A.k4(this,b),0),a)
else throw A.c(A.cT("`setTimeout()` not found."))}}
A.k4.prototype={
$0(){this.b.$0()},
$S:1}
A.af.prototype={
gD(){var s=this.b
return s==null?this.$ti.c.a(s):s},
dA(a,b){var s,r,q
a=A.K(a)
b=b
s=this.a
for(;;)try{r=s(this,a,b)
return r}catch(q){b=q
a=1}},
q(){var s,r,q,p,o=this,n=null,m=0
for(;;){s=o.d
if(s!=null)try{if(s.q()){o.b=s.gD()
return!0}else o.d=null}catch(r){n=r
m=1
o.d=null}q=o.dA(m,n)
if(1===q)return!0
if(0===q){o.b=null
p=o.e
if(p==null||p.length===0){o.a=A.no
return!1}if(0>=p.length)return A.a(p,-1)
o.a=p.pop()
m=0
n=null
continue}if(2===q){m=0
n=null
continue}if(3===q){n=o.c
o.c=null
p=o.e
if(p==null||p.length===0){o.b=null
o.a=A.no
throw n
return!1}if(0>=p.length)return A.a(p,-1)
o.a=p.pop()
m=1
continue}throw A.c(A.ck("sync*"))}return!1},
ew(a){var s,r,q=this
if(a instanceof A.br){s=a.a()
r=q.e
if(r==null)r=q.e=[]
B.b.l(r,q.a)
q.a=s
return 2}else{q.d=J.bu(a)
return 2}},
$iV:1}
A.br.prototype={
gC(a){return new A.af(this.a(),this.$ti.h("af<1>"))}}
A.bd.prototype={
k(a){return A.r(this.a)},
$ia3:1,
gb1(){return this.b}}
A.f5.prototype={
cw(a){var s=this.a
if((s.a&30)!==0)throw A.c(A.ck("Future already completed"))
s.c2(A.rx(a,null))}}
A.dJ.prototype={}
A.dO.prototype={
eg(a){if((this.c&15)!==6)return!0
return this.b.b.bP(t.al.a(this.d),a.a,t.y,t.K)},
e4(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.ag.b(q))p=l.el(q,m,a.b,o,n,t.l)
else p=l.bP(t.E.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.eK.b(A.ac(s))){if((r.c&1)!==0)throw A.c(A.aG("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.c(A.aG("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.b_.prototype={
eo(a,b,c){var s,r,q=this.$ti
q.L(c).h("1/(2)").a(a)
s=$.ak
if(s===B.k){if(!t.ag.b(b)&&!t.E.b(b))throw A.c(A.fp(b,"onError",u.c))}else{c.h("@<0/>").L(q.c).h("1(2)").a(a)
b=A.rQ(b,s)}r=new A.b_(s,c.h("b_<0>"))
this.c0(new A.dO(r,3,a,b,q.h("@<1>").L(c).h("dO<1,2>")))
return r},
dD(a){this.a=this.a&1|16
this.c=a},
bb(a){this.a=a.a&30|this.a&1
this.c=a.c},
c0(a){var s,r=this,q=r.a
if(q<=3){a.a=t.d.a(r.c)
r.c=a}else{if((q&4)!==0){s=t.D.a(r.c)
if((s.a&24)===0){s.c0(a)
return}r.bb(s)}A.fk(null,null,r.b,t.M.a(new A.ju(r,a)))}},
cm(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.d.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t.D.a(m.c)
if((n.a&24)===0){n.cm(a)
return}m.bb(n)}l.a=m.bh(a)
A.fk(null,null,m.b,t.M.a(new A.jy(l,m)))}},
bg(){var s=t.d.a(this.c)
this.c=null
return this.bh(s)},
bh(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
d1(a){var s,r=this
r.$ti.c.a(a)
s=r.bg()
r.a=8
r.c=a
A.cV(r,s)},
d0(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.bg()
q.bb(a)
A.cV(q,r)},
c6(a){var s=this.bg()
this.dD(a)
A.cV(this,s)},
cX(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("cG<1>").b(a)){this.d_(a)
return}this.cY(a)},
cY(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.fk(null,null,s.b,t.M.a(new A.jw(s,a)))},
d_(a){A.lD(this.$ti.h("cG<1>").a(a),this,!1)
return},
c2(a){this.a^=2
A.fk(null,null,this.b,t.M.a(new A.jv(this,a)))},
$icG:1}
A.ju.prototype={
$0(){A.cV(this.a,this.b)},
$S:1}
A.jy.prototype={
$0(){A.cV(this.b,this.a.a)},
$S:1}
A.jx.prototype={
$0(){A.lD(this.a.a,this.b,!0)},
$S:1}
A.jw.prototype={
$0(){this.a.d1(this.b)},
$S:1}
A.jv.prototype={
$0(){this.a.c6(this.b)},
$S:1}
A.jB.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.ek(t.fO.a(q.d),t.z)}catch(p){s=A.ac(p)
r=A.eg(p)
if(k.c&&t.u.a(k.b.a.c).a===s){q=k.a
q.c=t.u.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.l1(q)
n=k.a
n.c=new A.bd(q,o)
q=n}q.b=!0
return}if(j instanceof A.b_&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.u.a(j.c)
q.b=!0}return}if(j instanceof A.b_){m=k.b.a
l=new A.b_(m.b,m.$ti)
j.eo(new A.jC(l,m),new A.jD(l),t.aT)
q=k.a
q.c=l
q.b=!1}},
$S:1}
A.jC.prototype={
$1(a){this.a.d0(this.b)},
$S:19}
A.jD.prototype={
$2(a,b){A.cv(a)
t.l.a(b)
this.a.c6(new A.bd(a,b))},
$S:77}
A.jA.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.bP(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.ac(l)
r=A.eg(l)
q=s
p=r
if(p==null)p=A.l1(q)
o=this.a
o.c=new A.bd(q,p)
o.b=!0}},
$S:1}
A.jz.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.u.a(l.a.a.c)
p=l.b
if(p.a.eg(s)&&p.a.e!=null){p.c=p.a.e4(s)
p.b=!1}}catch(o){r=A.ac(o)
q=A.eg(o)
p=t.u.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.l1(p)
m=l.b
m.c=new A.bd(p,n)
p=m}p.b=!0}},
$S:1}
A.f3.prototype={}
A.e8.prototype={$in3:1}
A.fa.prototype={
em(a){var s,r,q
t.M.a(a)
try{if(B.k===$.ak){a.$0()
return}A.nS(null,null,this,a,t.aT)}catch(q){s=A.ac(q)
r=A.eg(q)
A.lR(A.cv(s),t.l.a(r))}},
dU(a){return new A.k1(this,t.M.a(a))},
ek(a,b){b.h("0()").a(a)
if($.ak===B.k)return a.$0()
return A.nS(null,null,this,a,b)},
bP(a,b,c,d){c.h("@<0>").L(d).h("1(2)").a(a)
d.a(b)
if($.ak===B.k)return a.$1(b)
return A.rV(null,null,this,a,b,c,d)},
el(a,b,c,d,e,f){d.h("@<0>").L(e).L(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.ak===B.k)return a.$2(b,c)
return A.rU(null,null,this,a,b,c,d,e,f)}}
A.k1.prototype={
$0(){return this.a.em(this.b)},
$S:1}
A.kx.prototype={
$0(){A.oX(this.a,this.b)},
$S:1}
A.dP.prototype={
gB(a){return this.a},
gO(a){return this.a===0},
gZ(a){return this.a!==0},
ga9(){return new A.cq(this,this.$ti.h("cq<1>"))},
gaU(){var s=this.$ti
return A.dl(new A.cq(this,s.h("cq<1>")),new A.jE(this),s.c,s.y[1])},
a8(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.d5(a)},
d5(a){var s=this.d
if(s==null)return!1
return this.aP(this.cb(s,a),a)>=0},
m(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.lF(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.lF(q,b)
return r}else return this.df(b)},
df(a){var s,r,q=this.d
if(q==null)return null
s=this.cb(q,a)
r=this.aP(s,a)
return r<0?null:s[r+1]},
u(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.c_(s==null?m.b=A.lG():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.c_(r==null?m.c=A.lG():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.lG()
p=A.ei(b)&1073741823
o=q[p]
if(o==null){A.lH(q,p,[b,c]);++m.a
m.e=null}else{n=m.aP(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
ad(a,b){var s=this
if(typeof b=="string"&&b!=="__proto__")return s.c5(s.b,b)
else if(typeof b=="number"&&(b&1073741823)===b)return s.c5(s.c,b)
else return s.dw(b)},
dw(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=A.ei(a)&1073741823
r=n[s]
q=o.aP(r,a)
if(q<0)return null;--o.a
o.e=null
p=r.splice(q,2)[1]
if(0===r.length)delete n[s]
return p},
aL(a,b){var s,r,q,p,o,n,m=this,l=m.$ti
l.h("~(1,2)").a(b)
s=m.c8()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.m(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.c(A.ag(m))}},
c8(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.aA(i.a,null,!1,t.z)
s=i.b
r=0
if(s!=null){q=Object.getOwnPropertyNames(s)
p=q.length
for(o=0;o<p;++o){h[r]=q[o];++r}}n=i.c
if(n!=null){q=Object.getOwnPropertyNames(n)
p=q.length
for(o=0;o<p;++o){h[r]=+q[o];++r}}m=i.d
if(m!=null){q=Object.getOwnPropertyNames(m)
p=q.length
for(o=0;o<p;++o){l=m[q[o]]
k=l.length
for(j=0;j<k;j+=2){h[r]=l[j];++r}}}return i.e=h},
c_(a,b,c){var s=this.$ti
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.lH(a,b,c)},
c5(a,b){var s
if(a!=null&&a[b]!=null){s=this.$ti.y[1].a(A.lF(a,b))
delete a[b];--this.a
this.e=null
return s}else return null},
cb(a,b){return a[A.ei(b)&1073741823]}}
A.jE.prototype={
$1(a){var s=this.a,r=s.$ti
s=s.m(0,r.c.a(a))
return s==null?r.y[1].a(s):s},
$S(){return this.a.$ti.h("2(1)")}}
A.cW.prototype={
aP(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.cq.prototype={
gB(a){return this.a.a},
gO(a){return this.a.a===0},
gZ(a){return this.a.a!==0},
gC(a){var s=this.a
return new A.dQ(s,s.c8(),this.$ti.h("dQ<1>"))},
J(a,b){return this.a.a8(b)}}
A.dQ.prototype={
gD(){var s=this.d
return s==null?this.$ti.c.a(s):s},
q(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.c(A.ag(p))
else if(q>=r.length){s.d=null
return!1}else{s.d=r[q]
s.c=q+1
return!0}},
$iV:1}
A.bJ.prototype={
gC(a){var s=this,r=new A.ba(s,s.r,A.q(s).h("ba<1>"))
r.c=s.e
return r},
gB(a){return this.a},
gO(a){return this.a===0},
gZ(a){return this.a!==0},
J(a,b){var s,r
if(typeof b=="string"&&b!=="__proto__"){s=this.b
if(s==null)return!1
return t.g.a(s[b])!=null}else if(typeof b=="number"&&(b&1073741823)===b){r=this.c
if(r==null)return!1
return t.g.a(r[b])!=null}else return this.d4(b)},
d4(a){var s=this.d
if(s==null)return!1
return this.aP(s[this.c7(a)],a)>=0},
gR(a){var s=this.f
if(s==null)throw A.c(A.ck("No elements"))
return A.q(this).c.a(s.a)},
l(a,b){var s,r,q=this
A.q(q).c.a(b)
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.bZ(s==null?q.b=A.lI():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.bZ(r==null?q.c=A.lI():r,b)}else return q.cV(b)},
cV(a){var s,r,q,p=this
A.q(p).c.a(a)
s=p.d
if(s==null)s=p.d=A.lI()
r=p.c7(a)
q=s[r]
if(q==null)s[r]=[p.bu(a)]
else{if(p.aP(q,a)>=0)return!1
q.push(p.bu(a))}return!0},
bZ(a,b){A.q(this).c.a(b)
if(t.g.a(a[b])!=null)return!1
a[b]=this.bu(b)
return!0},
bu(a){var s=this,r=new A.f8(A.q(s).c.a(a))
if(s.e==null)s.e=s.f=r
else s.f=s.f.b=r;++s.a
s.r=s.r+1&1073741823
return r},
c7(a){return J.aM(a)&1073741823},
aP(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.N(a[r].a,b))return r
return-1},
$imq:1}
A.f8.prototype={}
A.ba.prototype={
gD(){var s=this.d
return s==null?this.$ti.c.a(s):s},
q(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.c(A.ag(q))
else if(r==null){s.d=null
return!1}else{s.d=s.$ti.h("1?").a(r.a)
s.c=r.b
return!0}},
$iV:1}
A.hm.prototype={
$2(a,b){this.a.u(0,this.b.a(a),this.c.a(b))},
$S:75}
A.P.prototype={
gC(a){return new A.b6(a,this.gB(a),A.bt(a).h("b6<P.E>"))},
a0(a,b){return this.m(a,b)},
gO(a){return this.gB(a)===0},
gZ(a){return!this.gO(a)},
gR(a){if(this.gB(a)===0)throw A.c(A.aY())
return this.m(a,this.gB(a)-1)},
J(a,b){var s,r=this.gB(a)
for(s=0;s<r;++s){if(J.N(this.m(a,s),b))return!0
if(r!==this.gB(a))throw A.c(A.ag(a))}return!1},
X(a,b){var s,r
A.bt(a).h("w(P.E)").a(b)
s=this.gB(a)
for(r=0;r<s;++r){if(b.$1(this.m(a,r)))return!0
if(s!==this.gB(a))throw A.c(A.ag(a))}return!1},
H(a,b){var s
if(this.gB(a)===0)return""
s=A.lp("",a,b)
return s.charCodeAt(0)==0?s:s},
ap(a,b,c){var s=A.bt(a)
return new A.t(a,s.L(c).h("1(P.E)").a(b),s.h("@<P.E>").L(c).h("t<1,2>"))},
N(a,b){return A.eW(a,0,A.ee(b,"count",t.p),A.bt(a).h("P.E"))},
bj(a,b){return new A.bx(a,A.bt(a).h("@<P.E>").L(b).h("bx<1,2>"))},
bn(a,b){var s
A.bt(a).h("w(P.E)").a(b)
for(s=0;s<this.gB(a);++s)if(b.$1(this.m(a,s)))return s
return-1},
k(a){return A.l5(a,"[","]")}}
A.Q.prototype={
bk(a,b,c){var s=A.q(this)
return A.mt(this,s.h("Q.K"),s.h("Q.V"),b,c)},
aL(a,b){var s,r,q,p=A.q(this)
p.h("~(Q.K,Q.V)").a(b)
for(s=this.ga9(),s=s.gC(s),p=p.h("Q.V");s.q();){r=s.gD()
q=this.m(0,r)
b.$2(r,q==null?p.a(q):q)}},
gaw(){var s=this.ga9(),r=A.q(this).h("a0<Q.K,Q.V>"),q=A.q(s)
return A.dl(s,q.L(r).h("1(m.E)").a(new A.ho(this)),q.h("m.E"),r)},
ej(a,b){var s,r,q,p,o,n=this,m=A.q(n)
m.h("w(Q.K,Q.V)").a(b)
s=A.d([],m.h("F<Q.K>"))
for(r=n.ga9(),r=r.gC(r),m=m.h("Q.V");r.q();){q=r.gD()
p=n.m(0,q)
if(b.$2(q,p==null?m.a(p):p))B.b.l(s,q)}for(m=s.length,o=0;o<s.length;s.length===m||(0,A.M)(s),++o)n.ad(0,s[o])},
gB(a){var s=this.ga9()
return s.gB(s)},
gO(a){var s=this.ga9()
return s.gO(s)},
gZ(a){var s=this.ga9()
return s.gZ(s)},
gaU(){return new A.dR(this,A.q(this).h("dR<Q.K,Q.V>"))},
k(a){return A.lb(this)},
$iaa:1}
A.ho.prototype={
$1(a){var s=this.a,r=A.q(s)
r.h("Q.K").a(a)
s=s.m(0,a)
if(s==null)s=r.h("Q.V").a(s)
return new A.a0(a,s,r.h("a0<Q.K,Q.V>"))},
$S(){return A.q(this.a).h("a0<Q.K,Q.V>(Q.K)")}}
A.hp.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.r(a)
r.a=(r.a+=s)+": "
s=A.r(b)
r.a+=s},
$S:29}
A.dR.prototype={
gB(a){var s=this.a
return s.gB(s)},
gO(a){var s=this.a
return s.gO(s)},
gZ(a){var s=this.a
return s.gZ(s)},
gR(a){var s=this.a,r=s.ga9()
r=s.m(0,r.gR(r))
return r==null?this.$ti.y[1].a(r):r},
gC(a){var s=this.a,r=s.ga9()
return new A.dS(r.gC(r),s,this.$ti.h("dS<1,2>"))}}
A.dS.prototype={
q(){var s=this,r=s.a
if(r.q()){s.c=s.b.m(0,r.gD())
return!0}s.c=null
return!1},
gD(){var s=this.c
return s==null?this.$ti.y[1].a(s):s},
$iV:1}
A.bC.prototype={
gO(a){return this.gB(this)===0},
gZ(a){return this.gB(this)!==0},
aJ(a,b){var s
for(s=J.bu(A.q(this).h("m<1>").a(b));s.q();)this.l(0,s.gD())},
ap(a,b,c){var s=A.q(this)
return new A.c6(this,s.L(c).h("1(2)").a(b),s.h("@<1>").L(c).h("c6<1,2>"))},
gaD(a){var s,r=this
if(r.gB(r)>1)throw A.c(A.mk())
s=r.gC(r)
if(!s.q())throw A.c(A.aY())
return s.gD()},
k(a){return A.l5(this,"{","}")},
N(a,b){return A.n0(this,b,A.q(this).c)},
gR(a){var s,r=this.gC(this)
if(!r.q())throw A.c(A.aY())
do s=r.gD()
while(r.q())
return s},
a0(a,b){var s,r
A.eQ(b,"index")
s=this.gC(this)
for(r=b;s.q();){if(r===0)return s.gD();--r}throw A.c(A.h9(b,b-r,this,"index"))},
$iy:1,
$im:1,
$icj:1}
A.e1.prototype={}
A.er.prototype={}
A.eu.prototype={}
A.dh.prototype={
k(a){var s=A.ex(this.a)
return(this.b!=null?"Converting object to an encodable object failed:":"Converting object did not return an encodable object:")+" "+s}}
A.eE.prototype={
k(a){return"Cyclic error in JSON stringify"}}
A.he.prototype={
dY(a,b){var s=A.qR(a,this.gdZ().b,null)
return s},
gdZ(){return B.hC}}
A.hf.prototype={}
A.jH.prototype={
cJ(a){var s,r,q,p,o,n,m=a.length
for(s=this.c,r=0,q=0;q<m;++q){p=a.charCodeAt(q)
if(p>92){if(p>=55296){o=p&64512
if(o===55296){n=q+1
n=!(n<m&&(a.charCodeAt(n)&64512)===56320)}else n=!1
if(!n)if(o===56320){o=q-1
o=!(o>=0&&(a.charCodeAt(o)&64512)===55296)}else o=!1
else o=!0
if(o){if(q>r)s.a+=B.a.F(a,r,q)
r=q+1
o=A.av(92)
s.a+=o
o=A.av(117)
s.a+=o
o=A.av(100)
s.a+=o
o=p>>>8&15
o=A.av(o<10?48+o:87+o)
s.a+=o
o=p>>>4&15
o=A.av(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.av(o<10?48+o:87+o)
s.a+=o}}continue}if(p<32){if(q>r)s.a+=B.a.F(a,r,q)
r=q+1
o=A.av(92)
s.a+=o
switch(p){case 8:o=A.av(98)
s.a+=o
break
case 9:o=A.av(116)
s.a+=o
break
case 10:o=A.av(110)
s.a+=o
break
case 12:o=A.av(102)
s.a+=o
break
case 13:o=A.av(114)
s.a+=o
break
default:o=A.av(117)
s.a+=o
o=A.av(48)
s.a=(s.a+=o)+o
o=p>>>4&15
o=A.av(o<10?48+o:87+o)
s.a+=o
o=p&15
o=A.av(o<10?48+o:87+o)
s.a+=o
break}}else if(p===34||p===92){if(q>r)s.a+=B.a.F(a,r,q)
r=q+1
o=A.av(92)
s.a+=o
o=A.av(p)
s.a+=o}}if(r===0)s.a+=a
else if(r<m)s.a+=B.a.F(a,r,m)},
bt(a){var s,r,q,p
for(s=this.a,r=s.length,q=0;q<r;++q){p=s[q]
if(a==null?p==null:a===p)throw A.c(new A.eE(a,null))}B.b.l(s,a)},
bo(a){var s,r,q,p,o=this
if(o.cI(a))return
o.bt(a)
try{s=o.b.$1(a)
if(!o.cI(s)){q=A.mp(a,null,o.gcl())
throw A.c(q)}q=o.a
if(0>=q.length)return A.a(q,-1)
q.pop()}catch(p){r=A.ac(p)
q=A.mp(a,r,o.gcl())
throw A.c(q)}},
cI(a){var s,r,q=this
if(typeof a=="number"){if(!isFinite(a))return!1
q.c.a+=B.f.k(a)
return!0}else if(a===!0){q.c.a+="true"
return!0}else if(a===!1){q.c.a+="false"
return!0}else if(a==null){q.c.a+="null"
return!0}else if(typeof a=="string"){s=q.c
s.a+='"'
q.cJ(a)
s.a+='"'
return!0}else if(t._.b(a)){q.bt(a)
q.er(a)
s=q.a
if(0>=s.length)return A.a(s,-1)
s.pop()
return!0}else if(t.r.b(a)){q.bt(a)
r=q.es(a)
s=q.a
if(0>=s.length)return A.a(s,-1)
s.pop()
return r}else return!1},
er(a){var s,r,q=this.c
q.a+="["
s=J.aj(a)
if(s.gZ(a)){this.bo(s.m(a,0))
for(r=1;r<s.gB(a);++r){q.a+=","
this.bo(s.m(a,r))}}q.a+="]"},
es(a){var s,r,q,p,o,n,m=this,l={}
if(a.gO(a)){m.c.a+="{}"
return!0}s=a.gB(a)*2
r=A.aA(s,null,!1,t.O)
q=l.a=0
l.b=!0
a.aL(0,new A.jI(l,r))
if(!l.b)return!1
p=m.c
p.a+="{"
for(o='"';q<s;q+=2,o=',"'){p.a+=o
m.cJ(A.I(r[q]))
p.a+='":'
n=q+1
if(!(n<s))return A.a(r,n)
m.bo(r[n])}p.a+="}"
return!0}}
A.jI.prototype={
$2(a,b){var s,r
if(typeof a!="string")this.a.b=!1
s=this.b
r=this.a
B.b.u(s,r.a++,a)
B.b.u(s,r.a++,b)},
$S:29}
A.jG.prototype={
gcl(){var s=this.c.a
return s.charCodeAt(0)==0?s:s}}
A.ab.prototype={
n(a){var s,r,q=this,p=q.c
if(p===0)return q
s=!q.a
r=q.b
p=A.aF(p,r)
return new A.ab(p===0?!1:s,r,p)},
d8(a){var s,r,q,p,o,n,m,l=this.c
if(l===0)return $.p()
s=l+a
r=this.b
q=new Uint16Array(s)
for(p=l-1,o=r.length;p>=0;--p){n=p+a
if(!(p<o))return A.a(r,p)
m=r[p]
if(!(n>=0&&n<s))return A.a(q,n)
q[n]=m}o=this.a
n=A.aF(s,q)
return new A.ab(n===0?!1:o,q,n)},
d9(a){var s,r,q,p,o,n,m,l,k=this,j=k.c
if(j===0)return $.p()
s=j-a
if(s<=0)return k.a?$.m5():$.p()
r=k.b
q=new Uint16Array(s)
for(p=r.length,o=a;o<j;++o){n=o-a
if(!(o>=0&&o<p))return A.a(r,o)
m=r[o]
if(!(n<s))return A.a(q,n)
q[n]=m}n=k.a
m=A.aF(s,q)
l=new A.ab(m===0?!1:n,q,m)
if(n)for(o=0;o<a;++o){if(!(o<p))return A.a(r,o)
if(r[o]!==0)return l.G(0,$.o())}return l},
aj(a,b){var s,r,q,p,o,n=this
if(b<0)throw A.c(A.aG("shift-amount must be posititve "+b,null))
s=n.c
if(s===0)return n
r=B.c.S(b,16)
if(B.c.W(b,16)===0)return n.d8(r)
q=s+r+1
p=new Uint16Array(q)
A.n9(n.b,s,b,p)
s=n.a
o=A.aF(q,p)
return new A.ab(o===0?!1:s,p,o)},
ak(a,b){var s,r,q,p,o,n,m,l,k,j=this
if(b<0)throw A.c(A.aG("shift-amount must be posititve "+b,null))
s=j.c
if(s===0)return j
r=B.c.S(b,16)
q=B.c.W(b,16)
if(q===0)return j.d9(r)
p=s-r
if(p<=0)return j.a?$.m5():$.p()
o=j.b
n=new Uint16Array(p)
A.bX(o,s,b,n)
s=j.a
m=A.aF(p,n)
l=new A.ab(m===0?!1:s,n,m)
if(s){s=o.length
if(!(r>=0&&r<s))return A.a(o,r)
if((o[r]&B.c.aj(1,q)-1)!==0)return l.G(0,$.o())
for(k=0;k<r;++k){if(!(k<s))return A.a(o,k)
if(o[k]!==0)return l.G(0,$.o())}}return l},
j(a,b){var s,r
t.cl.a(b)
s=this.a
if(s===b.a){r=A.aJ(this.b,this.c,b.b,b.c)
return s?0-r:r}return s?-1:1},
br(a,b){var s,r,q,p=this,o=p.c,n=a.c
if(o<n)return a.br(p,b)
if(o===0)return $.p()
if(n===0)return p.a===b?p:p.n(0)
s=o+1
r=new Uint16Array(s)
A.bo(p.b,o,a.b,n,r)
q=A.aF(s,r)
return new A.ab(q===0?!1:b,r,q)},
ba(a,b){var s,r,q,p=this,o=p.c
if(o===0)return $.p()
s=a.c
if(s===0)return p.a===b?p:p.n(0)
r=new Uint16Array(o)
A.a5(p.b,o,a.b,s,r)
q=A.aF(o,r)
return new A.ab(q===0?!1:b,r,q)},
A(a,b){var s,r,q=this,p=q.c
if(p===0)return b
s=b.c
if(s===0)return q
r=q.a
if(r===b.a)return q.br(b,r)
if(A.aJ(q.b,p,b.b,s)>=0)return q.ba(b,r)
return b.ba(q,!r)},
G(a,b){var s,r,q=this,p=q.c
if(p===0)return b.n(0)
s=b.c
if(s===0)return q
r=q.a
if(r!==b.a)return q.br(b,r)
if(A.aJ(q.b,p,b.b,s)>=0)return q.ba(b,r)
return b.ba(q,!r)},
i(a,b){var s,r,q,p,o,n,m,l=this.c,k=b.c
if(l===0||k===0)return $.p()
s=l+k
r=this.b
q=b.b
p=new Uint16Array(s)
for(o=q.length,n=0;n<k;){if(!(n<o))return A.a(q,n)
A.na(q[n],r,0,p,n,l);++n}o=this.a!==b.a
m=A.aF(s,p)
return new A.ab(m===0?!1:o,p,m)},
a2(a){var s,r,q,p
if(this.c<a.c)return $.p()
this.c9(a)
s=$.lz.al()-$.dL.al()
r=A.cU($.ly.al(),$.dL.al(),$.lz.al(),s)
q=A.aF(s,r)
p=new A.ab(!1,r,q)
return this.a!==a.a&&q>0?p.n(0):p},
bE(a){var s,r,q,p=this
if(p.c<a.c)return p
p.c9(a)
s=A.cU($.ly.al(),0,$.dL.al(),$.dL.al())
r=A.aF($.dL.al(),s)
q=new A.ab(!1,s,r)
if($.lA.al()>0)q=q.ak(0,$.lA.al())
return p.a&&q.c>0?q.n(0):q},
c9(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=c.c
if(b===$.n6&&a.c===$.n8&&c.b===$.n5&&a.b===$.n7)return
s=a.b
r=a.c
q=r-1
if(!(q>=0&&q<s.length))return A.a(s,q)
p=16-B.c.gt(s[q])
if(p>0){o=new Uint16Array(r+5)
n=A.lC(s,r,p,o)
m=new Uint16Array(b+5)
l=A.lC(c.b,b,p,m)}else{m=A.cU(c.b,0,b,b+2)
n=r
o=s
l=b}q=n-1
if(!(q>=0&&q<o.length))return A.a(o,q)
k=o[q]
j=l-n
i=new Uint16Array(l)
h=A.lB(o,n,j,i)
g=l+1
q=m.$flags|0
if(A.aJ(m,l,i,h)>=0){q&2&&A.a8(m)
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=1
A.a5(m,g,i,h,m)}else{q&2&&A.a8(m)
if(!(l>=0&&l<m.length))return A.a(m,l)
m[l]=0}q=n+2
f=new Uint16Array(q)
if(!(n>=0&&n<q))return A.a(f,n)
f[n]=1
A.a5(f,n+1,o,n,f)
e=l-1
for(q=m.length;j>0;){d=A.qM(k,m,e);--j
A.na(d,f,0,m,j,n)
if(!(e>=0&&e<q))return A.a(m,e)
if(m[e]<d){h=A.lB(f,n,j,i)
A.a5(m,g,i,h,m)
while(--d,m[e]<d)A.a5(m,g,i,h,m)}--e}$.n5=c.b
$.n6=b
$.n7=s
$.n8=r
$.ly.b=m
$.lz.b=g
$.dL.b=n
$.lA.b=p},
gU(a){var s,r,q,p,o=new A.ji(),n=this.c
if(n===0)return 6707
s=this.a?83585:429689
for(r=this.b,q=r.length,p=0;p<n;++p){if(!(p<q))return A.a(r,p)
s=o.$2(s,r[p])}return new A.jj().$1(s)},
I(a,b){if(b==null)return!1
return b instanceof A.ab&&this.j(0,b)===0},
gt(a){var s,r,q,p,o,n,m=this.c
if(m===0)return 0
s=this.b
r=m-1
q=s.length
if(!(r>=0&&r<q))return A.a(s,r)
p=s[r]
o=16*r+B.c.gt(p)
if(!this.a)return o
if((p&p-1)!==0)return o
for(n=m-2;n>=0;--n){if(!(n<q))return A.a(s,n)
if(s[n]!==0)return o}return o-1},
au(a,b){if(b.c===0)throw A.c(B.e)
return this.a2(b)},
cF(a,b){if(b.c===0)throw A.c(B.e)
return this.bE(b)},
W(a,b){var s
if(b.c===0)throw A.c(B.e)
s=this.bE(b)
if(s.a)s=b.a?s.G(0,b):s.A(0,b)
return s},
gE(a){if(this.c===0)return 0
return this.a?-1:1},
a1(a){var s,r
if(a<0)throw A.c(A.aG("Exponent must not be negative: "+a,null))
if(a===0)return $.o()
s=$.o()
for(r=this;a!==0;){if((a&1)===1)s=s.i(0,r)
a=B.c.aI(a,1)
if(a!==0)r=r.i(0,r)}return s},
aC(a,b){var s=this
if(s.c===0)return b.a?b.n(0):b
if(b.c===0)return s.a?s.n(0):s
return A.qL(s,b,!1)},
ai(a){var s,r,q,p
for(s=this.c-1,r=this.b,q=r.length,p=0;s>=0;--s){if(!(s<q))return A.a(r,s)
p=p*65536+r[s]}return this.a?-p:p},
aB(a){var s,r,q,p,o,n,m,l,k=this,j={},i=k.c
if(i===0)return 0
s=new Uint8Array(8);--i
r=k.b
q=r.length
if(!(i>=0&&i<q))return A.a(r,i)
p=16*i+B.c.gt(r[i])
if(p>1024)return k.a?-1/0:1/0
if(k.a)s[7]=128
o=p-53+1075
s[6]=(o&15)<<4
s[7]=(s[7]|B.c.aI(o,4))>>>0
j.a=j.b=0
j.c=i
n=new A.jk(j,k)
i=n.$1(5)
if(typeof i!=="number")return i.eu()
s[6]=s[6]|i&15
for(m=5;m>=0;--m)B.E.u(s,m,n.$1(8))
l=new A.jl(s)
if(J.N(n.$1(1),1))if((s[0]&1)===1)l.$0()
else if(j.b!==0)l.$0()
else for(m=j.c;m>=0;--m){if(!(m<q))return A.a(r,m)
if(r[m]!==0){l.$0()
break}}return J.m9(B.E.gcu(s)).getFloat64(0,!0)},
k(a){var s,r,q,p,o,n=this,m=n.c
if(m===0)return"0"
if(m===1){if(n.a){m=n.b
if(0>=m.length)return A.a(m,0)
return B.c.k(-m[0])}m=n.b
if(0>=m.length)return A.a(m,0)
return B.c.k(m[0])}s=A.d([],t.s)
m=n.a
r=m?n.n(0):n
while(r.c>1){q=$.m4()
if(q.c===0)A.x(B.e)
p=r.bE(q).k(0)
B.b.l(s,p)
o=p.length
if(o===1)B.b.l(s,"000")
if(o===2)B.b.l(s,"00")
if(o===3)B.b.l(s,"0")
r=r.a2(q)}q=r.b
if(0>=q.length)return A.a(q,0)
B.b.l(s,B.c.k(q[0]))
if(m)B.b.l(s,"-")
return new A.ci(s,t.bp).eb(0)},
$ia9:1,
$iaH:1}
A.ji.prototype={
$2(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
$S:8}
A.jj.prototype={
$1(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
$S:7}
A.jk.prototype={
$1(a){var s,r,q,p,o,n,m,l
for(s=this.a,r=this.b,q=r.c-1,r=r.b,p=r.length;o=s.a,o<a;){o=s.c
if(o<0){s.c=o-1
n=0
m=16}else{if(!(o<p))return A.a(r,o)
n=r[o]
m=o===q?B.c.gt(n):16;--s.c}s.b=B.c.aj(s.b,m)+n
s.a+=m}r=s.b
o-=a
l=B.c.ak(r,o)
s.b=r-B.c.aj(l,o)
s.a=o
return l},
$S:7}
A.jl.prototype={
$0(){var s,r,q,p,o
for(s=this.a,r=s.$flags|0,q=1,p=0;p<8;++p){if(q===0)break
o=s[p]+q
r&2&&A.a8(s)
s[p]=o&255
q=o>>>8}},
$S:1}
A.c5.prototype={
I(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.c5)if(this.a===b.a)s=this.b===b.b
return s},
gU(a){return A.dv(this.a,this.b,B.i,B.i)},
j(a,b){var s
t.dy.a(b)
s=B.c.j(this.a,b.a)
if(s!==0)return s
return B.c.j(this.b,b.b)},
k(a){var s=this,r=A.oU(A.pQ(s)),q=A.ev(A.pO(s)),p=A.ev(A.pK(s)),o=A.ev(A.pL(s)),n=A.ev(A.pN(s)),m=A.ev(A.pP(s)),l=A.mj(A.pM(s)),k=s.b,j=k===0?"":A.mj(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"},
$iaH:1}
A.jq.prototype={
k(a){return this.aX()}}
A.a3.prototype={
gb1(){return A.pJ(this)}}
A.el.prototype={
k(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.ex(s)
return"Assertion failed"}}
A.bF.prototype={}
A.b3.prototype={
gbw(){return"Invalid argument"+(!this.a?"(s)":"")},
gbv(){return""},
k(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gbw()+q+o
if(!s.a)return n
return n+s.gbv()+": "+A.ex(s.gbM())},
gbM(){return this.b}}
A.dz.prototype={
gbM(){return A.ny(this.b)},
gbw(){return"RangeError"},
gbv(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.r(q):""
else if(q==null)s=": Not greater than or equal to "+A.r(r)
else if(q>r)s=": Not in inclusive range "+A.r(r)+".."+A.r(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.r(r)
return s}}
A.ey.prototype={
gbM(){return A.K(this.b)},
gbw(){return"RangeError"},
gbv(){if(A.K(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gB(a){return this.f}}
A.dH.prototype={
k(a){return"Unsupported operation: "+this.a}}
A.f_.prototype={
k(a){return"UnimplementedError: "+this.a}}
A.cP.prototype={
k(a){return"Bad state: "+this.a}}
A.et.prototype={
k(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.ex(s)+"."}}
A.dC.prototype={
k(a){return"Stack Overflow"},
gb1(){return null},
$ia3:1}
A.js.prototype={
k(a){return"Exception: "+this.a}}
A.T.prototype={
k(a){var s=this.a,r=""!==s?"FormatException: "+s:"FormatException",q=this.b
if(typeof q=="string"){if(q.length>78)q=B.a.F(q,0,75)+"..."
return r+"\n"+q}else return r}}
A.ez.prototype={
gb1(){return null},
k(a){return"IntegerDivisionByZeroException"},
$ia3:1}
A.m.prototype={
bj(a,b){return A.fJ(this,A.q(this).h("m.E"),b)},
ap(a,b,c){var s=A.q(this)
return A.dl(this,s.L(c).h("1(m.E)").a(b),s.h("m.E"),c)},
J(a,b){var s
for(s=this.gC(this);s.q();)if(J.N(s.gD(),b))return!0
return!1},
cE(a,b){var s,r
A.q(this).h("m.E(m.E,m.E)").a(b)
s=this.gC(this)
if(!s.q())throw A.c(A.aY())
r=s.gD()
while(s.q())r=b.$2(r,s.gD())
return r},
aA(a,b,c,d){var s,r
d.a(b)
A.q(this).L(d).h("1(1,m.E)").a(c)
for(s=this.gC(this),r=b;s.q();)r=c.$2(r,s.gD())
return r},
az(a,b){var s
A.q(this).h("w(m.E)").a(b)
for(s=this.gC(this);s.q();)if(!b.$1(s.gD()))return!1
return!0},
H(a,b){var s,r,q=this.gC(this)
if(!q.q())return""
s=J.b2(q.gD())
if(!q.q())return s
r=b.gO(b)
if(r){r=s
do r+=J.b2(q.gD())
while(q.q())}else{r=s
do r=r+A.r(b)+J.b2(q.gD())
while(q.q())}return r.charCodeAt(0)==0?r:r},
X(a,b){var s
A.q(this).h("w(m.E)").a(b)
for(s=this.gC(this);s.q();)if(b.$1(s.gD()))return!0
return!1},
gB(a){var s,r=this.gC(this)
for(s=0;r.q();)++s
return s},
gO(a){return!this.gC(this).q()},
gZ(a){return!this.gO(this)},
N(a,b){return A.n0(this,b,A.q(this).h("m.E"))},
gP(a){var s=this.gC(this)
if(!s.q())throw A.c(A.aY())
return s.gD()},
gR(a){var s,r=this.gC(this)
if(!r.q())throw A.c(A.aY())
do s=r.gD()
while(r.q())
return s},
a0(a,b){var s,r
A.eQ(b,"index")
s=this.gC(this)
for(r=b;s.q();){if(r===0)return s.gD();--r}throw A.c(A.h9(b,b-r,this,"index"))},
k(a){return A.p0(this,"(",")")}}
A.a0.prototype={
k(a){return"MapEntry("+A.r(this.a)+": "+A.r(this.b)+")"}}
A.aD.prototype={
gU(a){return A.z.prototype.gU.call(this,0)},
k(a){return"null"}}
A.z.prototype={$iz:1,
I(a,b){return this===b},
gU(a){return A.dx(this)},
k(a){return"Instance of '"+A.dy(this)+"'"},
ga4(a){return A.to(this)},
toString(){return this.k(this)}}
A.ff.prototype={
k(a){return""},
$icO:1}
A.bm.prototype={
gB(a){return this.a.length},
k(a){var s=this.a
return s.charCodeAt(0)==0?s:s},
$iqm:1}
A.hW.prototype={
k(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.kH.prototype={
$1(a){var s,r,q,p
if(A.nQ(a))return a
s=this.a
if(s.a8(a))return s.m(0,a)
if(t.r.b(a)){r={}
s.u(0,a,r)
for(s=a.ga9(),s=s.gC(s);s.q();){q=s.gD()
r[q]=this.$1(a.m(0,q))}return r}else if(t.hf.b(a)){p=[]
s.u(0,a,p)
B.b.aJ(p,J.d7(a,this,t.z))
return p}else return a},
$S:20}
A.kN.prototype={
$1(a){var s=this.a,r=s.$ti
a=r.h("1/?").a(this.b.h("0/?").a(a))
s=s.a
if((s.a&30)!==0)A.x(A.ck("Future already completed"))
s.cX(r.h("1/").a(a))
return null},
$S:22}
A.kO.prototype={
$1(a){if(a==null)return this.a.cw(new A.hW(a===undefined))
return this.a.cw(a)},
$S:22}
A.kz.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.nP(a))return a
s=this.a
a.toString
if(s.a8(a))return s.m(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.x(A.aw(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.ee(!0,"isUtc",t.y)
return new A.c5(r,0,!0)}if(a instanceof RegExp)throw A.c(A.aG("structured clone of RegExp",null))
if(a instanceof Promise)return A.tK(a,t.O)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.O
o=A.X(p,p)
s.u(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.ar(n),p=s.gC(n);p.q();)m.push(A.o_(p.gD()))
for(l=0;l<s.gB(n);++l){k=s.m(n,l)
if(!(l<m.length))return A.a(m,l)
j=m[l]
if(k!=null)o.u(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.u(0,a,o)
h=A.K(a.length)
for(s=J.aj(i),l=0;l<h;++l)o.push(this.$1(s.m(i,l)))
return o}return a},
$S:20}
A.dn.prototype={
aX(){return"NativeBridgeStatus."+this.b}}
A.eo.prototype={
bs(){var s,r,q=this
if(q.c)return!0
try{if(!$.mW){s=v.G
if(A.cZ(s.symEngineReady)&&A.nx(s.symEngineInstance)!=null){A.rs()
$.mW=!0}else A.x(A.lx("SymEngine (web build)"))}q.b=new A.cl()
q.c=!0
s=$.kX()
if(s.a!==B.A)s.seq(B.A)}catch(r){q.b=null
q.c=!1}return q.c},
gaF(){if(!this.c&&$.kX().a===B.A)this.bs()
return this.b},
gaM(){if(!this.c&&$.kX().a===B.A)this.bs()
return this.c},
ag(a,b){var s,r,q,p,o,n,m
t.b5.a(b)
s=this.gaF()
if(s==null)return"Error: "+a+" requires native library"
try{p=b.$1(s)
return p}catch(o){r=A.ac(o)
A.r(r)
p=J.b2(r)
n=A.l("^Exception:\\s*",!0)
q=A.A(p,n,"")
if(J.aV(q,"RuntimeError")||J.aV(q,"Aborted"))return"Error: expression not supported in web mode"
m=B.a.p(q)
p=!0
if(m.length!==0)if(m!=="null")if(m!=="[object Object]")if(!B.a.v(m,"[object ")){p=A.l('^\\{\\s*"?excPtr"?\\s*:',!0)
p=p.b.test(m)}if(p)return"Error: "+a+" failed"
return"Error: "+a+" failed: "+A.r(q)}},
K(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=A.aX(a)
if(f!=null){if(!B.a.J(f,"/")){s=A.l("\\bsqrt\\s*\\(",!0)
s=s.b.test(a)}else s=!0
g.a=new A.ax(B.F,s?B.y:B.dU,!1,null)
return f}r=A.oY(a)
if(r!=null){g.a=B.w
return r}q=A.oZ(a)
if(q!=null)return g.K(q)
s=!1
if(a.length<=512){p=A.l("\\b(?:ln|log|log2|log10|lg)\\s*\\(",!0)
if(p.b.test(a)){s=A.l("\\babs\\s*\\(",!0)
s=s.b.test(a)}}if(s){o=A.l(u.j,!0).am(0,a).X(0,new A.fv(a))?null:A.au(a)
if(o!=null){n=o.K(B.u)
if(n==null||!isFinite(n)){g.a=null
return"Error: logarithm/absolute-value expression is undefined or nonfinite"}g.a=B.o
s=A.li(a)
s.toString
return s}}if(g.gaM()&&B.a.J(a,"Matrix(")){m=A.pi(a,g)
if(m!=null)return m}if(!g.gaM()){l=A.li(a)
if(l!=null){g.a=B.o
return l}}k=g.ag("evaluate",new A.fw(a))
if(B.a.v(k,"Error:")){l=A.li(a)
if(l!=null){g.a=B.o
return l}j=A.bn(a)
if(j!=null)return j
i=A.qo(a)
if(i!=null)return i
h=A.th(A.lr(a))
if(h!=null)return h}return k},
e0(a){var s,r,q,p,o,n=this.gaF()
if(n==null)return"Error"
q=this.cZ(a)
if(q!=null)return q
try{p=B.a.p(a)
p=A.A(p,",",".")
s=A.A(p," ","")
r=A.bL("flutter_symengine_evaluate",A.I(s))
p=this.dd(r)
return p}catch(o){return"Error"}},
dd(a){var s,r,q
if(a.length===0)return a
s=B.a.p(a)
r=$.of()
s=A.A(s,r,"")
r=$.oc()
s=A.A(s,r,"")
r=$.oe()
s=B.a.p(A.A(s,r," "))
if(s.length!==0){r=$.ob()
r=r.b.test(s)}else r=!0
if(r){q=$.od().a3(a)
if(q==null)s=null
else{r=q.b
if(1>=r.length)return A.a(r,1)
r=r[1]
s=r}if(s==null)s="0"}return s},
cO(a,b){var s,r,q,p,o,n,m,l,k,j,i,h=this,g=" = (no solutions)"
h.a=null
n=A.oR(a,b)
if(n!=null){h.a=B.w
m=n.length
if(m===0)return b+g
return m===1?b+" = "+B.b.gaD(n):b+" = {"+B.b.H(n,", ")+"}"}l=A.mK(a,b)
k=l==null?null:A.j4(l.k(0),b)
if(k!=null){h.a=B.w
m=k.length
if(m===0)return b+g
return m===1?b+" = "+B.b.gaD(k):b+" = {"+B.b.H(k,", ")+"}"}m=A.mK(a,b)
l=m==null?null:m.k(0)
s=l==null?a:l
r=h.gaF()
if(r==null){j=A.j4(s,b)
if(j!=null){m=j.length
if(m===0)return b+g
if(m>1)return b+" = {"+B.b.H(j,", ")+"}"
return b+" = "+B.b.gaD(j)}return"Error: solve requires native library"}try{q=A.ea("flutter_symengine_solve",A.I(s),b)
if(J.b1(q,"Error"))return q
if(J.b1(q,"[")&&J.mb(q,"]")){p=J.md(q,1,J.S(q)-1)
if(J.S(p)===0)return b+g
if(J.aV(p,",")){m=A.r(p)
return b+" = {"+m+"}"}m=A.r(p)
return b+" = "+m}m=A.r(q)
return b+" = "+m}catch(i){o=A.ac(i)
A.r(o)
return"Error: solve failed"}},
cz(a){var s,r
if(this.gaM()){s=this.ag("factor",new A.fy(a))
if(!B.a.v(s,"Error"))return s}r=A.n_(a)
if(r!=null)return r
return this.ag("factor",new A.fz(a))},
e1(a,b){var s
if(!this.gaM()){s=A.bn(b)
if(s!=null)return s}return this.ag("expand",new A.fx(b))},
a6(a){var s,r=this,q=A.pG(a)
if(q!=null){r.a=new A.ax(B.m,B.M,!1,q.a)
return q.b}if(!r.gaM()){s=A.bn(a)
if(s!=null){r.a=B.hN
return s}}return r.ag("simplify",new A.fG(a))},
a7(a,b){var s
if(!this.gaM()){s=A.qE(a,b)
if(s!=null)return s}return this.ag("differentiate",new A.fu(a,b))},
aE(a,b,c){var s=A.l("^[A-Za-z_][A-Za-z_0-9]*$",!0)
if(!s.b.test(b)||B.a.p(c).length===0)return"Error: invalid substitution variable or value"
return A.kU(a,A.l(u.j,!0),t.A.a(t.I.a(new A.fI(b,a,c))),null)},
dS(a,b){return this.ag("besselj",new A.fs(a,b))},
dT(a,b){return this.ag("bessely",new A.ft(a,b))},
cZ(a){var s,r,q,p,o,n="Error",m=A.l("^(besselj|bessely)\\s*\\(\\s*(-?\\d+)\\s*,\\s*\\(?\\s*(-?\\d*\\.?\\d+(?:[eE][+-]?\\d+)?)\\s*\\)?\\s*\\)$",!0).a3(B.a.p(a))
if(m==null)return null
q=m.b
if(2>=q.length)return A.a(q,2)
q=q[2]
q.toString
s=A.bk(q,null)
if(s==null)return null
try{q=m.b
if(1>=q.length)return A.a(q,1)
q=q[1]
q.toString
if(q==="besselj"){q=m.b
if(3>=q.length)return A.a(q,3)
q=q[3]
q.toString
p=this.dS(s,q)}else{q=m.b
if(3>=q.length)return A.a(q,3)
q=q[3]
q.toString
p=this.dT(s,q)}r=p
q=J.b1(r,n)?n:r
return q}catch(o){return n}},
bm(a){if(a<0)return"Error: factorial requires non-negative integer"
return this.ag("factorial",new A.fA(a))},
e2(a){if(a<0)return"Error: fibonacci requires non-negative integer"
return this.ag("fibonacci",new A.fB(a))},
bV(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i=this,h="flutter_symengine_series"
i.a=null
if(c<1||c>64)return"Error: order must be in 1..64"
p=A.qb(a,b,d,c-1)
if(p!=null){if(!B.a.v(p,"Error"))i.a=B.v
return p}o=A.qa(a,b,d)
if(o!=null)return i.bV(o,b,c,d)
if(a.length<=512){n=A.l("^[A-Za-z_][A-Za-z0-9_]*$",!0)
n=n.b.test(b)&&A.aX(d)!=null}else n=!1
if(n){m=A.bn(a)
l=m==null?null:A.cf(m)
if(l!=null)n=l.a.length-1<=0||l.b!==b
else n=!1
if(n){i.a=B.v
return l.k(0)}}s=i.gaF()
if(s==null)return"Error: series requires native library"
try{n=v.G
if(!A.cZ(n._symHasExport("flutter_symengine_series"))){n=s.gcN()
n=A.tW(a,b,s.gdX(),c,d,n,i.gcS())
return n}if(!A.cZ(n._symHasExport("flutter_symengine_series")))A.x(A.lx("SymEngine series (web build)"))
k=A.I(n._symCcall3StrInt.apply(n,[h,a,b,d,c]))
if(B.a.v(k,"Error"))A.x(A.ap(h,k,null))
r=k
n=A.lY(r)?"Error: series failed: not expandable at this point":A.o5(r,b)
return n}catch(j){q=A.ac(j)
A.r(q)
return"Error: series failed"}},
cP(a,b){var s,r,q,p,o,n,m,l,k,j,i=t.a
i.a(a)
i.a(b)
this.a=null
l=A.p4(a,b)
if(l!=null){if(!B.a.v(l,"Error"))this.a=B.w
return l}if(a.length!==b.length)return"Error: linsolve requires a certified exact proof for rectangular systems"
s=this.gaF()
if(s==null||!A.cZ(v.G._symHasExport("flutter_symengine_linsolve")))return"Error: linsolve requires a newer native library for this syntax"
try{if(!A.cZ(v.G._symHasExport("flutter_symengine_linsolve")))A.x(A.lx("SymEngine linsolve (web build)"))
r=A.ea("flutter_symengine_linsolve",B.b.H(a,"; "),B.b.H(b,", "))
q=J.bv(r)
if(J.b1(q,"[")&&J.mb(q,"]"))q=J.md(q,1,J.S(q)-1)
p=A.oL(q)
if(J.S(p)!==b.length)return r
o=A.d([],t.s)
n=0
for(;;){i=n
k=b.length
if(typeof i!=="number")return i.af()
if(!(i<k))break
J.fo(o,B.b.m(b,n)+" = "+B.a.p(J.aL(p,n)))
i=n
if(typeof i!=="number")return i.A()
n=i+1}i=J.l0(o,", ")
return i}catch(j){m=A.ac(j)
A.r(m)
return"Error: linsolve failed (system not linear or no unique solution)"}},
cK(a,b,c){return this.ag("gcd",new A.fC(b,c))},
ed(a,b){return this.ag("lcm",new A.fD(a,b))},
ee(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h,g=this
g.a=null
s=A.qd(a,b,c)
if(s!=null){g.a=B.v
return s}if(A.qe(a,b,c)){g.a=B.v
return"0"}r=A.l("\\b(?:abs|sign|floor|ceil|Piecewise|Heaviside)\\s*\\(",!0)
q=r.b.test(a)?null:A.qw(g,a,c,b)
r=!1
if(q!=null){p=A.l("\\b(?:Derivative|Subs|undefined|nan|zoo|Error)\\b",!1)
o=q.a
if(!p.b.test(o)){r=A.l("\\b(?:oo|inf|infinity)\\b",!1)
if(r.b.test(o)){r=A.l("^[+-]?(?:oo|inf|infinity)$",!1)
o=B.a.p(o)
r=r.b.test(o)}else r=!0}}if(r){g.a=B.v
return q.a}g.a=null
n=g.gaF()
m=A.au(a)
if(n==null&&m==null)return"Error: limit requires native library"
r=new A.fF(g,m,b,a,n)
l=B.a.p(c)
if(l==="oo"||l==="inf"||l==="infinity"||l==="\\infty"){k=A.o3(r)
r=k!=null
if(r)g.a=B.o
return r?A.bw(k):"Error: limit at infinity does not converge"}if(l==="-oo"||l==="-inf"){k=A.o3(new A.fE(r))
r=k!=null
if(r)g.a=B.o
return r?A.bw(k):"Error: limit at -infinity does not converge"}j=A.bV(l)
if(j==null)return"Error: limit point must be a real number or \xb1oo"
k=A.tJ(r,j)
if(k==null){i=r.$1(j-1e-7)
h=r.$1(j+1e-7)
if(!isFinite(i)||!isFinite(h))return"Error: limit could not be computed (non-finite near "+c+")"
return"Error: left and right limits differ (left="+A.bw(i)+", right="+A.bw(h)+")"}g.a=B.o
return A.bw(k)},
e6(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e="Error: integrate requires native library"
f.a=null
s=f.gaF()
if(c==null||d==null){r=A.qF(a,b)
if(r!=null){f.a=B.hM
return r+" + C"}q=A.q8(f,a,b)
if(q!=null){f.a=B.hO
return q+" + C"}p=A.cQ(a,b,f,A.d([],t.gG))
if(p!=null){f.a=B.hP
return p+" + C"}return s==null?e:"Error: could not integrate (no matching rule)"}o=A.pW(a,b,c,d)
n=o==null
if(!n&&o.length!==0)return"Error: integration interval contains a divergent pole at "+b+" = "+B.b.H(o,", ")
m=A.pV(a,b,c,d)
if(m===!0)return"Error: integration interval contains a divergent pole"
if(n&&m==null&&A.ir(a,b)!=null)return"Error: cannot certify the rational integration interval domain"
l=A.qc(a,b,c,d)
if(l!=null){n=l.a
if(n!=null)return n
f.a=B.a_
n=l.b
n.toString
return A.bw(n)}k=A.pX(a,b)
if(k==null)k=a
j=A.qD(k,b,c,d)
if(j!=null){n=A.l("^[+-]?\\d+(?:/\\d+)?$",!0)
i=B.a.p(j)
f.a=new A.ax(n.b.test(i)?B.F:B.Z,B.L,!1,null)
return j}if(s!=null){p=A.cQ(k,b,f,A.d([],t.gG))
if(p!=null){h=A.oV(p,b,c,d)
g=h==null?null:A.bw(h)
if(g!=null){f.a=B.a_
return g}}return f.d7(s,k,b,c,d)}return e},
d7(a,b,c,d,e){var s,r,q,p
A.I(d)
A.I(e)
s=new A.fq(a)
r=s.$1(d)
q=s.$1(e)
if(r==null||q==null)return"Error: integration bounds must evaluate to numbers"
p=A.tO(new A.fr(this,A.au(b),c,b,a),r,q)
if(p==null)return"Error: integrand evaluation failed at some sample point"
this.a=B.hQ
return A.bw(p)},
bl(a,b){var s,r,q,p=null,o="matrix_create",n=this.gaF()
if(n==null)return p
try{if(a<=0||b<=0)A.x(A.ap(o,"Dimensions must be positive",p))
r=A.K(A.bs(v.G._symCcallPtrFromIntInt("flutter_symengine_matrix_new",a,b)))
if(r===0)A.x(A.ap(o,"allocation failed",p))
return new A.cR(r,a,b)}catch(q){s=A.ac(q)
A.r(s)
return p}}}
A.fv.prototype={
$1(a){var s,r
t.F.a(a)
s=a.b
if(0>=s.length)return A.a(s,0)
s=s[0]
s.toString
r=A.l("^[A-Za-z_]",!0)
if(!r.b.test(s))return!1
return!B.hS.J(0,s)&&!B.a.v(B.a.cH(B.a.M(this.a,a.gaK())),"(")},
$S:17}
A.fw.prototype={
$1(a){return A.bL("flutter_symengine_evaluate",this.a)},
$S:3}
A.fy.prototype={
$1(a){return A.bL("flutter_symengine_factor",this.a)},
$S:3}
A.fz.prototype={
$1(a){return A.bL("flutter_symengine_factor",this.a)},
$S:3}
A.fx.prototype={
$1(a){return A.bL("flutter_symengine_expand",this.a)},
$S:3}
A.fG.prototype={
$1(a){return A.bL("flutter_symengine_simplify",this.a)},
$S:3}
A.fu.prototype={
$1(a){return A.ea("flutter_symengine_differentiate",this.a,this.b)},
$S:3}
A.fI.prototype={
$1(a){var s=this.a
if(a.m(0,0)===s)s=B.a.v(B.a.cH(B.a.M(this.b,a.gaK())),"(")&&B.b.X(B.V,new A.fH(s))
else s=!0
if(s){s=a.m(0,0)
s.toString
return s}return"("+this.c+")"},
$S:12}
A.fH.prototype={
$1(a){var s
t.gY.a(a)
s=this.a
return a.a===s||B.a.v(a.c,s+"(")},
$S:55}
A.fs.prototype={
$1(a){return A.nA("flutter_symengine_besselj",this.a,this.b)},
$S:3}
A.ft.prototype={
$1(a){return A.nA("flutter_symengine_bessely",this.a,this.b)},
$S:3}
A.fA.prototype={
$1(a){return A.nz("flutter_symengine_factorial",this.a)},
$S:3}
A.fB.prototype={
$1(a){return A.nz("flutter_symengine_fibonacci",this.a)},
$S:3}
A.fC.prototype={
$1(a){return A.ea("flutter_symengine_gcd",this.a,this.b)},
$S:3}
A.fD.prototype={
$1(a){return A.ea("flutter_symengine_lcm",this.a,this.b)},
$S:3}
A.fF.prototype={
$1(a){var s,r,q,p,o,n=this
try{p=n.b
if(p!=null){s=p.K(A.B([n.c,a],t.N,t.V))
p=s!=null&&isFinite(s)?s:0/0
return p}r=n.a.aE(n.d,n.c,A.bw(a))
n.e.toString
q=A.bL("flutter_symengine_evaluate",A.I(r))
p=A.l3(q)
if(p==null)p=0/0
return p}catch(o){return 0/0}},
$S:0}
A.fE.prototype={
$1(a){return this.a.$1(-a)},
$S:0}
A.fq.prototype={
$1(a){var s,r,q=A.bV(a)
if(q!=null&&isFinite(q))return q
try{s=A.l3(A.bL("flutter_symengine_evaluate",a))
return s}catch(r){return null}},
$S:54}
A.fr.prototype={
$1(a){var s,r,q,p=this,o=p.b
if(o!=null){r=o.K(A.B([p.c,a],t.N,t.V))
return r!=null&&isFinite(r)?r:0/0}try{s=p.a.aE(p.d,p.c,A.bw(a))
o=A.l3(A.bL("flutter_symengine_evaluate",A.I(s)))
if(o==null)o=0/0
return o}catch(q){return 0/0}},
$S:0}
A.fN.prototype={
$1(a){var s,r,q,p
t.dX.a(a)
for(;;){s=!1
if(a.length>1){r=B.b.gR(a)
q=$.p()
p=r.a.a.j(0,q)
if(p===0)s=r.b.a.j(0,q)===0}if(!s)break
if(0>=a.length)return A.a(a,-1)
a.pop()}return a},
$S:53}
A.fM.prototype={
$2(a,b){var s,r,q,p,o,n,m,l=t.dX
l.a(a)
l.a(b)
l=a.length+b.length
if(l-2>2)throw A.c(B.Q)
s=A.aA(l-1,$.d5(),!0,t.cn)
r=0
for(;;){l=r
p=a.length
if(typeof l!=="number")return l.af()
if(!(l<p))break
q=0
for(;;){l=q
p=b.length
if(typeof l!=="number")return l.af()
if(!(l<p))break
l=r
p=q
if(typeof l!=="number")return l.A()
if(typeof p!=="number")return A.aU(p)
o=r
n=q
if(typeof o!=="number")return o.A()
if(typeof n!=="number")return A.aU(n)
n=J.aL(s,o+n)
o=B.b.m(a,r).i(0,B.b.m(b,q))
m=A.b8(n.a,o.a)
o=A.b8(n.b,o.b)
n=m.a
if((n.a?n.n(0):n).gt(0)+m.b.gt(0)>4096)A.x(B.n)
n=o.a
if((n.a?n.n(0):n).gt(0)+o.b.gt(0)>4096)A.x(B.n)
J.m7(s,l+p,new A.U(m,o))
l=q
if(typeof l!=="number")return l.A()
q=l+1}l=r
if(typeof l!=="number")return l.A()
r=l+1}return this.a.$1(s)},
$S:51}
A.fO.prototype={
$2(a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this,a4=a3.a.a+1
a3.a.a=a4
if(a4>256||a6>32)throw A.c(B.eu)
if(a5 instanceof A.v){f=$.J()
return A.d([new A.U(A.W(a5.a),A.W(f))],t.c)}f=a5 instanceof A.an
if(f&&a5.a==="I")return A.d([$.ot()],t.c)
if(f&&a5.a===a3.b)return A.d([$.d5(),$.kW()],t.c)
if(a5 instanceof A.ay){s=A.d([$.d5()],t.c)
for(f=a5.a,e=f.length,d=t.cn,c=a6+1,b=0;b<f.length;f.length===e||(0,A.M)(f),++b){r=f[b]
q=a3.$2(r,c)
a=J.S(s)>J.S(q)?J.S(s):J.S(q)
p=A.aA(a,$.d5(),!0,d)
o=0
for(;;){a=o
a0=J.S(p)
if(typeof a!=="number")return a.af()
if(!(a<a0))break
a=o
a0=o
a1=J.S(s)
if(typeof a0!=="number")return a0.af()
a0=a0<a1?J.aL(s,o):$.d5()
a1=o
a2=J.S(q)
if(typeof a1!=="number")return a1.af()
a1=a1<a2?J.aL(q,o):$.d5()
a2=A.b8(a0.a,a1.a)
a1=A.b8(a0.b,a1.b)
a0=a2.a
if((a0.a?a0.n(0):a0).gt(0)+a2.b.gt(0)>4096)A.x(B.n)
a0=a1.a
if((a0.a?a0.n(0):a0).gt(0)+a1.b.gt(0)>4096)A.x(B.n)
J.m7(p,a,new A.U(a2,a1))
a=o
if(typeof a!=="number")return a.A()
o=a+1}s=a3.c.$1(p)}return s}if(a5 instanceof A.a_){n=A.d([$.kW()],t.c)
for(f=a5.a,e=f.length,d=a6+1,b=0;b<f.length;f.length===e||(0,A.M)(f),++b){m=f[b]
n=a3.d.$2(n,a3.$2(m,d))}return n}if(a5 instanceof A.a7){l=A.aX(A.bN(a5.b))
k=l==null?null:A.jh(l,null)
if(k!=null){f=k
if(f.a)f=f.n(0)
f=f.j(0,A.C(128))>0}else f=!0
if(f)throw A.c(B.e8)
j=a3.$2(a5.a,a6+1)
i=k.ai(0)
f=i
if(typeof f!=="number")return f.af()
if(f<0){if(J.S(j)!==1)throw A.c(B.em)
j=A.d([J.mc(j).aS()],t.c)}if((J.S(j)-1)*J.d6(i)>2)throw A.c(B.Q)
h=A.d([$.kW()],t.c)
g=0
for(;;){f=g
e=J.d6(i)
if(typeof f!=="number")return f.af()
if(!(f<e))break
h=a3.d.$2(h,j)
f=g
if(typeof f!=="number")return f.A()
g=f+1}return h}throw A.c(B.ec)},
$S:50}
A.U.prototype={
A(a,b){var s=A.b8(this.a,b.a),r=A.b8(this.b,b.b)
return new A.U(A.W(s),A.W(r))},
i(a,b){var s=this.a,r=b.a,q=A.aQ(s,r),p=this.b,o=b.b,n=A.aQ(p,o)
n=A.b8(q,new A.f(n.a.n(0),n.b))
r=A.b8(A.aQ(s,o),A.aQ(p,r))
return new A.U(A.W(n),A.W(r))},
aS(){var s,r=this.a,q=this.b,p=A.b8(A.aQ(r,r),A.aQ(q,q)),o=p.a,n=o.j(0,$.p())
if(n===0)throw A.c(B.ea)
s=A.k(p.b,o)
r=A.aQ(r,s)
q=A.aQ(q,s)
o=q.a.n(0)
return new A.U(A.W(r),A.W(new A.f(o,q.b)))},
cQ(){var s,r,q,p,o,n=this.a,m=this.b,l=A.lE(A.b8(A.aQ(n,n),A.aQ(m,m)))
if(l==null)return null
s=A.b8(l,n)
r=$.o()
q=$.bO()
p=A.lE(A.aQ(s,A.k(r,q)))
o=A.lE(A.aQ(A.b8(l,new A.f(n.a.n(0),n.b)),A.k(r,q)))
if(p==null||o==null)n=null
else{n=m.a.gE(0)<0?new A.f(o.a.n(0),o.b):o
n=new A.U(A.W(p),A.W(n))}return n},
k(a){var s,r,q=this.b,p=q.a,o=$.p(),n=p.j(0,o)
if(n===0)return this.a.k(0)
n=p.a
s=n?p.n(0):p
q=q.b
if(new A.f(s,q).I(0,$.u()))r="I"
else r=new A.f(n?p.n(0):p,q).k(0)+"*I"
q=this.a
o=q.a.j(0,o)
if(o===0)return(p.gE(0)<0?"-":"")+r
q=q.k(0)
return q+(p.gE(0)<0?"-":"+")+r}}
A.cE.prototype={
bL(){var s=this.a,r=A.H(s)
return"{"+new A.t(s,r.h("i(1)").a(new A.fR()),r.h("t<1,i>")).H(0,", ")+"}"},
e3(){var s,r=this.b
if(r==null)return"N/A"
s=A.H(r)
return"{"+new A.t(r,s.h("i(1)").a(new A.fS()),s.h("t<1,i>")).H(0,", ")+"}"}}
A.fR.prototype={
$1(a){var s,r,q
t.cm.a(a)
s=a.b
r=Math.abs(s)
if(r<1e-10)return A.fQ(a.a)
q=s>=0?"+":"-"
return A.fQ(a.a)+" "+q+" "+A.fQ(r)+"i"},
$S:48}
A.fS.prototype={
$1(a){return"["+J.d7(t.H.a(a),A.tg(),t.N).H(0,", ")+"]"},
$S:46}
A.az.prototype={
k(a){var s=this.b,r=A.r(this.a)
return Math.abs(s)<1e-10?r:r+" + "+A.r(s)+"i"}}
A.ky.prototype={
$1(a){return J.S(t.H.a(a))!==this.a},
$S:44}
A.f1.prototype={
seq(a){this.a=this.$ti.c.a(a)}}
A.fT.prototype={
$2(a,b){return new A.R(A.aI(a.a.A(0,b.a)),A.aI(a.b.A(0,b.b)))},
$S:27}
A.fU.prototype={
$2(a,b){var s=a.a,r=b.a,q=a.b,p=b.b
return new A.R(A.aI(A.aI(s.i(0,r)).G(0,A.aI(q.i(0,p)))),A.aI(A.aI(s.i(0,p)).A(0,A.aI(q.i(0,r)))))},
$S:27}
A.fV.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this
if(++e.a.a>256||b>32)throw A.c(B.ee)
if(a instanceof A.v)return new A.R(A.aI(a.a),$.J())
if(a instanceof A.an&&a.a==="I")return new A.R($.J(),$.u())
s=a instanceof A.ay
if(s||a instanceof A.a_){r=s?$.J():$.u()
q=new A.R(r,$.J())
p=s?a.a:t.eb.a(a).a
for(r=p.length,o=e.c,n=b+1,m=e.b,l=0;l<p.length;p.length===r||(0,A.M)(p),++l){k=e.$2(p[l],n)
q=s?m.$2(q,k):o.$2(q,k)}return q}if(a instanceof A.aE&&a.a==="conjugate"&&a.b.length===1){k=e.$2(B.b.gaD(a.b),b+1)
s=k.a
r=k.b
return new A.R(s,new A.f(r.a.n(0),r.b))}if(a instanceof A.a7){j=A.l4(a.b)
s=!0
if(j!=null){r=j.b.j(0,$.o())
if(r===0){s=j.a
if(s.a)s=s.n(0)
s=s.j(0,A.C(128))>0}}if(s)throw A.c(B.ef)
i=e.$2(a.a,b+1)
h=j.a.ai(0)
if(h<0){s=i.a
r=A.aI(s.i(0,s))
o=i.b
g=A.aI(r.A(0,A.aI(o.i(0,o))))
r=g.a.j(0,$.p())
if(r===0)throw A.c(B.el)
i=new A.R(A.aI(s.ac(0,g)),A.aI(new A.f(o.a.n(0),o.b).ac(0,g)))}q=new A.R($.u(),$.J())
for(s=Math.abs(h),r=e.c,f=0;f<s;++f)q=r.$2(q,i)
return q}throw A.c(B.ei)},
$S:41}
A.fX.prototype={
$2(a,b){var s,r,q,p,o,n,m,l=this,k=l.a.a+1
l.a.a=k
if(k>256||b>32)throw A.c(B.eg)
if(a instanceof A.ay){p=a.a
o=A.H(p)
n=o.h("t<1,E>")
p=A.L(new A.t(p,o.h("E(1)").a(new A.fY(l,b)),n),n.h("D.E"))
return new A.ay(p)}if(a instanceof A.a_){p=a.a
o=A.H(p)
n=o.h("t<1,E>")
p=A.L(new A.t(p,o.h("E(1)").a(new A.fZ(l,b)),n),n.h("D.E"))
return new A.a_(p)}if(a instanceof A.aE){p=a.b
o=A.H(p)
n=o.h("t<1,E>")
p=A.L(new A.t(p,o.h("E(1)").a(new A.h_(l,b)),n),n.h("D.E"))
return new A.aE(a.a,p)}if(!(a instanceof A.a7))return a
p=a.a
s=A.l4(p)
o=a.b
r=A.l4(o)
n=!1
if(s!=null)if(r!=null)if(s.a.gE(0)<0){m=r.b.j(0,$.o())
if(m!==0)if(r.b.j(0,A.C(128))<=0){n=r.a
if(n.a)n=n.n(0)
n=n.j(0,A.C(128))<=0}}if(n){l.a.b=!0
p=t.h
q=new A.a_(A.d([B.hW,new A.v(r)],p))
o=s
n=o.a
if(n.a)n=n.n(0)
return new A.a_(A.d([new A.a7(new A.v(new A.f(n,o.b)),new A.v(r)),new A.ay(A.d([new A.aE("cos",A.d([q],p)),new A.a_(A.d([B.hV,new A.aE("sin",A.d([q],p))],p))],p))],p))}n=b+1
return new A.a7(l.$2(p,n),l.$2(o,n))},
$S:40}
A.fY.prototype={
$1(a){return this.a.$2(t.i.a(a),this.b+1)},
$S:9}
A.fZ.prototype={
$1(a){return this.a.$2(t.i.a(a),this.b+1)},
$S:9}
A.h_.prototype={
$1(a){return this.a.$2(t.i.a(a),this.b+1)},
$S:9}
A.fW.prototype={
$1(a){var s,r,q=this
t.i.a(a)
if(a instanceof A.v)return"("+a.a.k(0)+")"
if(a instanceof A.an)return a.a
if(a instanceof A.ay){s=a.a
r=A.H(s)
return"("+new A.t(s,r.h("i(1)").a(q),r.h("t<1,i>")).H(0,"+")+")"}if(a instanceof A.a_){s=a.a
r=A.H(s)
return"("+new A.t(s,r.h("i(1)").a(q),r.h("t<1,i>")).H(0,"*")+")"}if(a instanceof A.a7)return"("+A.r(q.$1(a.a))+")^("+A.r(q.$1(a.b))+")"
if(a instanceof A.aE){s=a.b
r=A.H(s)
return a.a+"("+new A.t(s,r.h("i(1)").a(q),r.h("t<1,i>")).H(0,",")+")"}throw A.c(B.et)},
$S:10}
A.Y.prototype={}
A.jp.prototype={
bT(){var s,r,q=this.a,p=q.length
for(;;){s=this.b
if(s<p){if(!(s>=0))return A.a(q,s)
r=B.a.p(q[s]).length===0}else r=!1
if(!r)break
this.b=s+1}},
N(a,b){var s,r=this
r.bT()
s=r.b
if(!B.a.bX(r.a,b,s))return!1
r.b=s+b.length
return!0},
an(a){if(++this.c>256||a.a.gt(0)>16384||a.b.gt(0)>16384)throw A.c(new A.Y())
return a},
aZ(){var s,r,q,p,o,n,m,l,k=this
if(++k.d>32)throw A.c(new A.Y())
try{s=k.cD()
for(p=t.G;;){r=k.N(0,"+")
if(!r&&!k.N(0,"-"))break
q=k.cD()
o=s.a
n=q.b
if(o.gt(0)+n.gt(0)>16384)A.x(new A.Y())
o=q.a
n=s.b
if(o.gt(0)+n.gt(0)>16384)A.x(new A.Y())
o=s.b
n=q.b
if(o.gt(0)+n.gt(0)>16384)A.x(new A.Y())
if(r){o=s
n=p.a(q)
m=n.b
l=o.a.i(0,m)
o=o.b
m=A.k(l.A(0,n.a.i(0,o)),o.i(0,m))
o=m}else{o=s
n=p.a(q)
m=n.b
l=o.a.i(0,m)
o=o.b
m=A.k(l.G(0,n.a.i(0,o)),o.i(0,m))
o=m}s=k.an(o)}p=s
return p}finally{--k.d}},
cD(){var s,r,q,p,o,n,m,l,k=this,j=k.b7()
for(;;){r=["*","/","%"]
q=0
for(;;){if(!(q<3)){s=null
break}p=r[q]
if(k.N(0,p)){s=p
break}++q}if(s==null)return j
o=k.b7()
if(s==="%"){r=$.o()
n=j.b.j(0,r)
m=!0
if(n===0){n=o.b.j(0,r)
if(n===0)n=o.a.j(0,$.p())===0
else n=m}else n=m
if(n)throw A.c(new A.Y())
j=k.an(A.k(j.a.W(0,o.a),r))}else if(s==="*"){r=j.a
n=o.a
if(r.gt(0)+n.gt(0)>16384)A.x(new A.Y())
m=j.b
l=o.b
if(m.gt(0)+l.gt(0)>16384)A.x(new A.Y())
j=k.an(A.k(r.i(0,n),m.i(0,l)))}else{r=o.a
n=r.j(0,$.p())
if(n===0)throw A.c(new A.Y())
n=j.a
m=o.b
if(n.gt(0)+m.gt(0)>16384)A.x(new A.Y())
l=j.b
if(l.gt(0)+r.gt(0)>16384)A.x(new A.Y())
j=k.an(A.k(n.i(0,m),l.i(0,r)))}}},
b7(){var s,r=this
if(++r.d>32)throw A.c(new A.Y())
try{if(r.N(0,"+")){s=r.b7()
return s}if(r.N(0,"-")){s=r.b7()
s=r.an(new A.f(s.a.n(0),s.b))
return s}s=r.eh()
return s}finally{--r.d}},
eh(){var s,r,q,p,o,n,m,l=this,k=l.ei()
while(l.N(0,"!"))k=l.bm(k)
if(!l.N(0,"^"))return k
s=l.b7()
r=s.b.j(0,$.o())
if(r===0){r=s.a
if(r.a)r=r.n(0)
r=r.j(0,A.C(1024))>0}else r=!0
if(r)throw A.c(new A.Y())
q=s.a.ai(0)
r=q<0
if(r)p=k.a.j(0,$.p())===0
else p=!1
if(p)throw A.c(new A.Y())
p=k.a
o=Math.abs(q)
if(p.gt(0)*o>16384||k.b.gt(0)*o>16384)throw A.c(new A.Y())
n=p.a1(o)
m=k.b.a1(o)
return l.an(r?A.k(m,n):A.k(n,m))},
ei(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=this
if(d.N(0,"factorial")){if(!d.N(0,"("))throw A.c(new A.Y())
s=d.aZ()
if(!d.N(0,")"))throw A.c(new A.Y())
return d.bm(s)}for(r=["floor","ceiling","ceil"],q=0;q<3;++q){p=r[q]
if(!d.N(0,p))continue
if(!d.N(0,"("))throw A.c(new A.Y())
s=d.aZ()
if(!d.N(0,")"))throw A.c(new A.Y())
r=s.a
o=s.b
if(o.c===0)A.x(B.e)
n=r.a2(o)
o=r.W(0,o).j(0,$.p())
if(o!==0){o=p==="floor"
if(o&&r.a)n=n.G(0,$.o())
else if(!o&&!r.a)n=n.A(0,$.o())}return d.an(A.k(n,$.o()))}if(d.N(0,"sqrt")){if(!d.N(0,"("))throw A.c(new A.Y())
s=d.aZ()
if(!d.N(0,")")||s.a.a)throw A.c(new A.Y())
return d.an(A.k(d.cC(s.a),d.cC(s.b)))}if(d.N(0,"abs")){if(!d.N(0,"("))throw A.c(new A.Y())
s=d.aZ()
if(!d.N(0,")"))throw A.c(new A.Y())
r=s.a
return d.an(r.a?new A.f(r.n(0),s.b):s)}if(d.N(0,"(")){s=d.aZ()
if(!d.N(0,")"))throw A.c(new A.Y())
return s}d.bT()
m=A.l("^(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE][+-]?\\d+)?",!0).a3(B.a.M(d.a,d.b))
if(m==null)throw A.c(new A.Y())
r=m.b
if(0>=r.length)return A.a(r,0)
l=r[0]
d.b=d.b+l.length
k=B.a.bW(l,A.l("[eE]",!0))
j=B.b.gP(k)
r=k.length
if(r===1)i=$.p()
else{if(1>=r)return A.a(k,1)
i=A.ae(k[1],null)}h=B.a.ao(j,".")
g=A.C(h<0?0:j.length-h-1).G(0,i)
r=g.a
o=r?g.n(0):g
if(o.j(0,A.C(4096))>0)throw A.c(new A.Y())
f=A.ae(A.A(j,".",""),null)
o=A.C(10)
e=o.a1((r?g.n(0):g).ai(0))
return d.an(r?A.k(f.i(0,e),$.o()):A.k(f,e))},
bm(a){var s,r,q,p=$.o(),o=a.b.j(0,p)
if(o===0){o=a.a
o=o.a||o.j(0,A.C(2048))>0}else o=!0
if(o)throw A.c(new A.Y())
s=a.a.ai(0)
for(r=2;r<=s;++r){q=A.C(r)
if(p.gt(0)+q.gt(0)>16384)A.x(new A.Y())
p=p.i(0,q)}return this.an(A.k(p,$.o()))},
cC(a){var s,r,q=$.p(),p=a.j(0,q)
if(p===0)return q
s=$.o().aj(0,B.c.S(a.gt(0)+1,2))
for(;;s=r){if(s.c===0)A.x(B.e)
r=s.A(0,a.a2(s)).ak(0,1)
if(r.j(0,s)>=0)break}if(!s.i(0,s).I(0,a))throw A.c(new A.Y())
return s}}
A.bf.prototype={
aX(){return"FunctionRefCategory."+this.b}}
A.b.prototype={}
A.j.prototype={}
A.kR.prototype={
$1(a){var s,r,q
A.aK(a)
s=A.B(["x",a],t.N,t.V)
r=this.a
if(r!=null)q=r.K(s)
else q=this.b.$2(this.c,s)
return A.d([a,q!=null&&isFinite(q)?q:null],t.en)},
$S:52}
A.h2.prototype={
b0(){var s,r,q,p=this,o=p.a,n=A.H(o),m=n.h("t<1,n<n<z>>>")
o=A.L(new A.t(o,n.h("n<n<z>>(1)").a(new A.h5()),m),m.h("D.E"))
n=p.b
m=A.H(n)
s=m.h("t<1,n<n<z>>>")
n=A.L(new A.t(n,m.h("n<n<z>>(1)").a(new A.h6()),s),s.h("D.E"))
m=p.c
s=A.H(m)
r=s.h("t<1,n<z>>")
m=A.L(new A.t(m,s.h("n<z>(1)").a(new A.h7()),r),r.h("D.E"))
s=p.d
r=A.H(s)
q=r.h("t<1,n<h>>")
s=A.L(new A.t(s,r.h("n<h>(1)").a(new A.h8()),q),q.h("D.E"))
return A.B(["curves",o,"markers",n,"special",m,"segments",s],t.N,t.z)}}
A.h5.prototype={
$1(a){var s=J.d7(t.el.a(a),new A.h4(),t.ew)
s=A.L(s,s.$ti.h("D.E"))
return s},
$S:72}
A.h4.prototype={
$1(a){t.au.a(a)
return A.d([a.b,a.c,a.a],t.f)},
$S:33}
A.h6.prototype={
$1(a){var s=J.d7(t.fM.a(a),new A.h3(),t.ew)
s=A.L(s,s.$ti.h("D.E"))
return s},
$S:35}
A.h3.prototype={
$1(a){t.cT.a(a)
return A.d([a.b,a.c,a.a],t.f)},
$S:36}
A.h7.prototype={
$1(a){t.au.a(a)
return A.d([a.b,a.c,a.a],t.f)},
$S:33}
A.h8.prototype={
$1(a){var s=t.bB.a(a).a
return A.d([s[0],s[2],s[1],s[3]],t.n)},
$S:37}
A.kS.prototype={
$1(a){var s=this.a
if(s!=null)s=s.K(A.B(["x",a],t.N,t.V))
else s=this.b.$2(this.c,A.B(["x",a],t.N,t.V))
return s},
$S:38}
A.kT.prototype={
$1(a){var s,r,q=this,p=q.a,o=-p
p=2*p
s=q.c
r=A.B(["x",o+p*q.b/s,"y",o+p*a/s],t.N,t.V)
p=q.d
if(p!=null)p=p.K(r)
else p=q.e.$2(q.f,r)
return p==null?0/0:p},
$S:39}
A.hh.prototype={
$1(a){var s
A.I(a)
s=A.l("^[A-Za-z][A-Za-z0-9_]*$",!0)
return!s.b.test(a)},
$S:11}
A.hi.prototype={
$1(a){return!B.b.J(this.a,A.I(a))},
$S:11}
A.hj.prototype={
$1(a){return A.K(a)!==0},
$S:2}
A.hk.prototype={
$1(a){var s
t.bJ.a(a)
s=J.ar(a)
if(s.N(a,this.a.length).az(0,new A.hg())){s=s.gR(a).a.j(0,$.p())
s=s!==0}else s=!1
return s},
$S:42}
A.hg.prototype={
$1(a){var s=t.G.a(a).a.j(0,$.p())
return s===0},
$S:43}
A.hr.prototype={
$1(a){return J.S(t.a.a(a))!==this.a},
$S:26}
A.hs.prototype={
$1(a){return J.S(t.a.a(a))!==B.b.gP(this.a).length},
$S:26}
A.ht.prototype={
$2(a,b){return A.K(a)+J.S(t.a.a(b))},
$S:45}
A.hu.prototype={
$1(a){return t.a.a(a)},
$S:25}
A.hv.prototype={
$1(a){return A.aX(B.a.p(A.I(a)))!=null},
$S:11}
A.hw.prototype={
$1(a){return t.a.a(a)},
$S:25}
A.hx.prototype={
$1(a){var s=B.a.p(A.I(a))
return this.a.b.test(s)},
$S:11}
A.f4.prototype={}
A.aC.prototype={
b9(a,b){var s,r,q,p,o
for(s=new A.O(b,A.q(b).h("O<1,2>")).gC(0),r=this.b;s.q();){q=s.d
p=q.b
o=p.a.j(0,$.p())
if(o!==0)r.u(0,J.l0(q.a,","),p)}},
gbR(){var s,r,q,p,o,n,m,l,k,j,i
for(s=this.b,s=new A.aP(s,s.r,s.e,A.q(s).h("aP<1>")),r=t.p,q=t.s,p=t.v,o=t.x,n=o.h("D.E"),m=t.t,l=0;s.q();){k=s.d
if(k.length===0)j=A.d([],m)
else j=A.L(new A.t(A.d(k.split(","),q),p.a(A.cx()),o),n)
i=B.b.aA(j,0,new A.hV(),r)
if(i>l)l=i}return l},
dW(a){var s,r,q,p,o,n,m,l,k
for(s=this.b,s=new A.aP(s,s.r,s.e,A.q(s).h("aP<1>")),r=t.s,q=t.v,p=t.x,o=p.h("D.E"),n=t.t,m=0;s.q();){l=s.d
if(l.length===0)k=A.d([],n)
else k=A.L(new A.t(A.d(l.split(","),r),q.a(A.cx()),p),o)
l=k.length
if(a<l&&k[a]>m){if(!(a<l))return A.a(k,a)
m=k[a]}}return m},
gae(){return new A.br(this.en(),t.dW)},
en(){var s=this
return function(){var r=0,q=1,p=[],o,n,m,l,k,j,i,h
return function $async$gae(a,b,c){if(b===1){p.push(c)
r=q}for(;;)switch(r){case 0:o=s.b,o=new A.O(o,A.q(o).h("O<1,2>")).gC(0),n=t.s,m=t.v,l=t.x,k=l.h("D.E"),j=t.t
case 2:if(!o.q()){r=3
break}i=o.d
h=i.a
if(h.length===0)h=A.d([],j)
else h=A.L(new A.t(A.d(h.split(","),n),m.a(A.cx()),l),k)
r=4
return a.b=new A.R(h,i.b),1
case 4:r=2
break
case 3:return 0
case 1:return a.c=p.at(-1),3}}}},
A(a,b){var s,r,q,p,o,n,m,l,k,j=A.eF(this.b,t.N,t.G)
for(s=b.b,s=new A.O(s,A.q(s).h("O<1,2>")).gC(0);s.q();){r=s.d
q=r.a
p=j.m(0,q)
o=r.b
if(p!=null){n=o.b
m=p.a.i(0,n)
l=p.b
k=A.k(m.A(0,o.a.i(0,l)),l.i(0,n))
o=k.a.j(0,$.p())
if(o===0)j.ad(0,q)
else j.u(0,q,k)}else j.u(0,q,o)}return new A.aC(this.a,j)},
G(a,b){var s,r,q,p,o,n,m,l,k,j=A.eF(this.b,t.N,t.G)
for(s=b.b,s=new A.O(s,A.q(s).h("O<1,2>")).gC(0);s.q();){r=s.d
q=r.a
p=j.m(0,q)
o=r.b
n=o.b
o=o.a
if(p!=null){m=p.a.i(0,n)
l=p.b
k=A.k(m.G(0,o.i(0,l)),l.i(0,n))
o=k.a.j(0,$.p())
if(o===0)j.ad(0,q)
else j.u(0,q,k)}else j.u(0,q,new A.f(o.n(0),n))}return new A.aC(this.a,j)},
i(a8,a9){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7=A.X(t.N,t.G)
for(s=this.b,s=new A.O(s,A.q(s).h("O<1,2>")).gC(0),r=a9.b,q=A.q(r).h("b5<1,2>"),p=t.t,o=this.a,n=t.s,m=t.v,l=t.x,k=l.h("D.E");s.q();){j=s.d
i=j.a
if(i.length===0)h=A.d([],p)
else h=A.L(new A.t(A.d(i.split(","),n),m.a(A.cx()),l),k)
for(i=new A.b5(r,r.r,r.e,q),g=j.b,f=g.a,g=g.b;i.q();){e=i.d
d=e.a
if(d.length===0)c=A.d([],p)
else c=A.L(new A.t(A.d(d.split(","),n),m.a(A.cx()),l),k)
b=o.length
a=A.d(new Array(b),p)
for(d=h.length,a0=c.length,a1=0;a1<b;++a1){if(!(a1<d))return A.a(h,a1)
a2=h[a1]
if(!(a1<a0))return A.a(c,a1)
a[a1]=a2+c[a1]}a3=B.b.H(a,",")
d=e.b
a4=A.k(f.i(0,d.a),g.i(0,d.b))
a5=a7.m(0,a3)
if(a5!=null){d=a4.b
a0=a5.a.i(0,d)
a2=a5.b
a6=A.k(a0.A(0,a4.a.i(0,a2)),a2.i(0,d))
d=a6.a.j(0,$.p())
if(d===0)a7.ad(0,a3)
else a7.u(0,a3,a6)}else{d=a4.a.j(0,$.p())
if(d!==0)a7.u(0,a3,a4)}}}return new A.aC(o,a7)},
a_(a){var s,r,q,p,o,n=a.a,m=n.j(0,$.p())
if(m===0)return new A.aC(this.a,A.X(t.N,t.G))
s=A.X(t.N,t.G)
for(m=this.b,m=new A.O(m,A.q(m).h("O<1,2>")).gC(0),r=a.b;m.q();){q=m.d
p=q.a
o=q.b
s.u(0,p,A.k(o.a.i(0,n),o.b.i(0,r)))}return new A.aC(this.a,s)},
I(a,b){var s,r,q,p
if(b==null)return!1
if(!(b instanceof A.aC))return!1
if(!this.dB(b))return!1
s=this.b
r=s.a
q=b.b
if(r!==q.a)return!1
for(s=new A.O(s,A.q(s).h("O<1,2>")).gC(0);s.q();){p=s.d
if(!J.N(q.m(0,p.a),p.b))return!1}return!0},
gU(a){return A.dv(this.a,this.b.a,B.i,B.i)},
dB(a){var s,r,q=this.a,p=q.length,o=a.a,n=o.length
if(p!==n)return!1
for(s=0;s<p;++s){r=q[s]
if(!(s<n))return A.a(o,s)
if(r!==o[s])return!1}return!0},
k(a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4=this.b
if(a4.a===0)return"0"
s=A.q(a4).h("O<1,2>")
r=A.L(new A.O(a4,s),s.h("m.E"))
B.b.aW(r,new A.hU())
q=new A.bm("")
for(a4=r.length,s=this.a,p=t.s,o=t.v,n=t.x,m=n.h("D.E"),l=t.t,k=0,j="";k<r.length;r.length===a4||(0,A.M)(r),++k){i=r[k]
h=i.a
if(h.length===0)g=A.d([],l)
else g=A.L(new A.t(A.d(h.split(","),p),o.a(A.cx()),n),m)
f=i.b
e=new A.bm("")
for(d=0;d<s.length;++d){if(!(d<g.length))return A.a(g,d)
h=g[d]
if(h===0)continue
c=e.a+=s[d]
if(h>1)e.a=c+("^"+h)}h=e.a
b=h.charCodeAt(0)==0?h:h
h=f.a
c=h.a?h.n(0):h
a=f.b
a0=new A.f(c,a)
if(j.length===0){if(h.gE(0)<0)q.a+="-"
j=b.length!==0
if(j){h=$.u()
a1=!1
a2=h.a.j(0,c)
if(a2===0)h=h.b.j(0,a)===0
else h=a1
h=!h}else h=!0
if(h){h=a0.k(0)
q.a+=h}h=!1
if(j){j=$.u()
a1=!1
c=j.a.j(0,c)
if(c===0)j=j.b.j(0,a)===0
else j=a1
if(!j){j=a.j(0,$.o())
j=j!==0}else j=h}else j=h
if(j)q.a+="*"
j=q.a+=b}else{j=h.gE(0)<0?" - ":" + "
j=q.a+=j
h=b.length!==0
if(h){a1=$.u()
a2=!1
a3=a1.a.j(0,c)
if(a3===0)a1=a1.b.j(0,a)===0
else a1=a2
a1=!a1}else a1=!0
if(a1){j+=a0.k(0)
q.a=j}a1=!1
if(h){h=$.u()
a2=!1
c=h.a.j(0,c)
if(c===0)h=h.b.j(0,a)===0
else h=a2
if(!h){h=a.j(0,$.o())
h=h!==0}else h=a1}else h=a1
j=(h?q.a=j+"*":j)+b
q.a=j}}return j.charCodeAt(0)==0?j:j}}
A.hV.prototype={
$2(a,b){return A.K(a)+A.K(b)},
$S:8}
A.hU.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k=t.e2
k.a(a)
k.a(b)
s=A.mC(a.a)
r=A.mC(b.a)
k=t.p
q=B.b.aA(s,0,new A.hS(),k)
p=B.b.aA(r,0,new A.hT(),k)
if(q!==p)return B.c.j(p,q)
for(k=s.length,o=r.length,n=0;n<k;++n){m=s[n]
if(!(n<o))return A.a(r,n)
l=r[n]
if(m!==l)return B.c.j(l,m)}return 0},
$S:47}
A.hS.prototype={
$2(a,b){return A.K(a)+A.K(b)},
$S:8}
A.hT.prototype={
$2(a,b){return A.K(a)+A.K(b)},
$S:8}
A.hz.prototype={
$1(a){return A.K(a)>0},
$S:2}
A.hA.prototype={
$1(a){return A.K(a)===0},
$S:2}
A.hF.prototype={
$1(a){return(A.K(a)&1)===1},
$S:2}
A.hG.prototype={
$1(a){return(A.K(a)&1)===1},
$S:2}
A.hH.prototype={
$1(a){return B.c.S(A.K(a),2)},
$S:7}
A.hI.prototype={
$1(a){return B.c.S(A.K(a),2)},
$S:7}
A.hO.prototype={
$1(a){return B.c.W(A.K(a),3)!==0},
$S:2}
A.hP.prototype={
$1(a){return B.c.W(A.K(a),3)!==0},
$S:2}
A.hQ.prototype={
$1(a){return B.c.S(A.K(a),3)},
$S:7}
A.hR.prototype={
$1(a){return B.c.S(A.K(a),3)},
$S:7}
A.hK.prototype={
$1(a){return(A.K(a)&1)===1},
$S:2}
A.hL.prototype={
$1(a){return(A.K(a)&1)===1},
$S:2}
A.hM.prototype={
$1(a){return B.c.S(A.K(a),2)},
$S:7}
A.hN.prototype={
$1(a){return B.c.S(A.K(a),2)},
$S:7}
A.hJ.prototype={
$1(a){return!J.aV(this.a,A.K(a))},
$S:2}
A.hC.prototype={
$2(a,b){A.K(a)
A.K(b)
return a>b?a:b},
$S:8}
A.hD.prototype={
$1(a){var s=t.Z.a(a).j(0,$.p())
return s!==0},
$S:24}
A.hB.prototype={
$1(a){return A.K(a)!==0},
$S:2}
A.jJ.prototype={
gaH(){var s=this.b,r=this.a,q=r.length
if(s<q){if(!(s>=0))return A.a(r,s)
s=r[s]}else s=null
return s},
cA(a){var s,r,q,p,o,n,m,l,k,j=this,i=j.a.length
if(i>512)return null
s=j.cj()
if(j.b<i)return null
if(a&&j.d.a<2)return null
i=j.d
r=A.L(i,A.q(i).c)
B.b.aV(r)
q=A.X(t.L,t.G)
for(i=new A.O(s,A.q(s).h("O<1,2>")).gC(0),p=t.p;i.q();){o=i.d
o.toString
n=A.aA(r.length,0,!1,p)
for(m=o.a.gaw(),m=m.gC(m);m.q();){l=m.gD()
B.b.u(n,B.b.ao(r,l.a),l.b)}m=q.m(0,n)
if(m==null)m=$.J()
o=o.b
l=o.b
k=m.b
q.u(0,n,A.k(m.a.i(0,l).A(0,o.a.i(0,k)),k.i(0,l)))}return A.cc(r,q)},
aN(){return this.cA(!0)},
cj(){if(++this.c>32)throw A.c(B.ej)
try{var s=this.dn()
return s}finally{--this.c}},
dn(){var s,r,q,p,o,n,m,l=this
if(l.gaH()==="+"){++l.b
s=!1}else{s=l.gaH()==="-"
if(s)++l.b}r=l.bD()
if(s)r=l.cg(r)
for(q=l.a,p=q.length;o=l.b,o<p;){n=o<p
if(n){if(!(o>=0))return A.a(q,o)
m=q[o]}else m=null
if(m==="+"){l.b=o+1
r=l.c1(r,l.bD())}else{if(n){if(!(o>=0))return A.a(q,o)
n=q[o]}else n=null
if(n==="-"){l.b=o+1
r=l.c1(r,l.cg(l.bD()))}else break}}return r},
bD(){var s,r,q,p,o,n,m,l,k=this,j=k.be()
for(s=k.a,r=s.length;q=k.b,q<r;){p=q<r
if(p){if(!(q>=0))return A.a(s,q)
o=s[q]}else o=null
if(o==="*"){k.b=q+1
j=k.by(j,k.be())}else{if(p){if(!(q>=0))return A.a(s,q)
p=s[q]}else p=null
if(p==="/"){k.b=q+1
n=k.be()
if(n.a!==1)throw A.c(B.S)
m=new A.O(n,A.q(n).h("O<1,2>")).gC(0)
if(!m.q())A.x(A.aY())
l=m.gD()
q=l.a.gaU()
if(q.X(q,new A.jL()))throw A.c(B.S)
q=$.u()
p=l.b
j=k.dC(j,A.k(q.a.i(0,p.b),q.b.i(0,p.a)))}else if(k.dF())j=k.by(j,k.be())
else break}}return j},
dF(){var s=this.gaH()
if(s==null)return!1
return A.ne(s)||s==="."||s==="("||A.lJ(s)},
be(){var s=this,r=s.dl()
if(s.gaH()==="^"){++s.b
r=s.dv(r,s.ck())}return r},
dl(){var s,r,q,p,o=this,n=o.gaH()
if(n==null)throw A.c(B.eo)
if(n==="("){++o.b
s=o.cj()
if(o.gaH()!==")")throw A.c(B.U);++o.b
return s}if(A.ne(n)||n===".")return o.ds()
if(A.lJ(n)){r=o.a
q=o.b
p=r.length
if(!(q>=0&&q<p))return A.a(r,q)
n=r[q];++q
if(q<p&&A.lJ(r[q]))A.x(B.eb);++o.b
o.d.l(0,n)
return A.B([A.B([n,1],t.N,t.p),$.u()],t.P,t.G)}throw A.c(A.dd("unexpected char: "+n,null))},
ds(){var s,r,q,p,o,n,m,l=this,k=l.b,j=l.a,i=j.length,h=k
for(;;){s=h<i
if(s){if(!(h>=0))return A.a(j,h)
r=j[h]
if(0>=r.length)return A.a(r,0)
q=r.charCodeAt(0)
r=q>=48&&q<=57}else r=!1
if(!r)break;++h
l.b=h}if(s){if(!(h>=0))return A.a(j,h)
s=j[h]==="."}else s=!1
if(s){++h
l.b=h
for(;;){if(h<i){if(!(h>=0))return A.a(j,h)
s=j[h]
if(0>=s.length)return A.a(s,0)
q=s.charCodeAt(0)
s=q>=48&&q<=57}else s=!1
if(!s)break;++h
l.b=h}}if(h<i){if(!(h>=0))return A.a(j,h)
s=j[h]==="/"&&h>k}else s=!1
if(s){p=B.a.F(j,k,h)
h=l.b=h+1
s=h
for(;;){if(s<i){if(!(s>=0))return A.a(j,s)
r=j[s]
if(0>=r.length)return A.a(r,0)
q=r.charCodeAt(0)
r=q>=48&&q<=57}else r=!1
if(!r)break;++s
l.b=s}if(s>h){o=B.a.F(j,h,s)
return A.B([A.X(t.N,t.p),A.k(A.ae(p,null),A.ae(o,null))],t.P,t.G)}i=l.b=h-1}else i=h
n=B.a.F(j,k,i)
m=A.qS(n)
if(m==null)throw A.c(A.dd("bad number: "+n,null))
return A.B([A.X(t.N,t.p),m],t.P,t.G)},
ck(){var s,r,q,p,o,n,m,l=this
if(l.gaH()==="("){++l.b
s=l.ck()
if(l.gaH()!==")")throw A.c(B.U);++l.b
return s}r=l.b
q=l.a
p=q.length
o=r
for(;;){if(o<p){if(!(o>=0))return A.a(q,o)
n=q[o]
if(0>=n.length)return A.a(n,0)
m=n.charCodeAt(0)
n=m>=48&&m<=57}else n=!1
if(!n)break;++o
l.b=o}if(o===r)throw A.c(B.eq)
return A.eh(B.a.F(q,r,o),null,null)},
cg(a){var s,r,q,p,o
t.X.a(a)
s=A.X(t.P,t.G)
for(r=new A.O(a,A.q(a).h("O<1,2>")).gC(0);r.q();){q=r.d
p=q.a
o=q.b
s.u(0,p,new A.f(o.a.n(0),o.b))}return s},
dC(a,b){var s,r,q
t.X.a(a)
s=A.X(t.P,t.G)
for(r=new A.O(a,A.q(a).h("O<1,2>")).gC(0);r.q();){q=r.d
s.u(0,q.a,this.c3(q.b,b))}return s},
c3(a,b){if(a.a.gt(0)+b.a.gt(0)>16384||a.b.gt(0)+b.b.gt(0)>16384)throw A.c(B.T)
return a.i(0,b)},
c4(a,b){var s,r=b.b
if(a.a.gt(0)+r.gt(0)<=16383){s=a.b
r=b.a.gt(0)+s.gt(0)>16383||s.gt(0)+r.gt(0)>16384}else r=!0
if(r)throw A.c(B.T)
return a.A(0,b)},
c1(a,b){var s,r,q,p,o,n,m,l,k,j=t.X
j.a(a)
j.a(b)
s=A.eF(a,t.P,t.G)
for(j=new A.O(b,A.q(b).h("O<1,2>")).gC(0),r=t.N,q=t.p;j.q();){p=j.d
o=p.a
n=this.ca(s,o)
m=p.b
if(n!=null){l=s.m(0,n)
l.toString
k=this.c4(l,m)
m=k.a.j(0,$.p())
if(m===0)s.ad(0,n)
else s.u(0,n,k)}else s.u(0,A.eF(o,r,q),m)}return s},
by(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=t.X
b.a(a)
b.a(a0)
if(A.lK(a)+A.lK(a0)>128||a.a*a0.a>512)throw A.c(B.ed)
s=A.X(t.P,t.G)
for(b=new A.O(a,A.q(a).h("O<1,2>")).gC(0),r=A.q(a0).h("b5<1,2>"),q=t.N,p=t.p;b.q();){o=b.d
for(n=new A.b5(a0,a0.r,a0.e,r),m=o.b,l=o.a;n.q();){k=n.d
k.toString
j=A.X(q,p)
for(i=l.gaw(),i=i.gC(i);i.q();){h=i.gD()
g=h.a
f=j.m(0,g)
if(f==null)f=0
j.u(0,g,f+h.b)}for(i=k.a.gaw(),i=i.gC(i);i.q();){h=i.gD()
g=h.a
f=j.m(0,g)
if(f==null)f=0
j.u(0,g,f+h.b)}j.ej(0,new A.jK())
e=this.c3(m,k.b)
d=this.ca(s,j)
if(d!=null){k=s.m(0,d)
k.toString
c=this.c4(k,e)
k=c.a.j(0,$.p())
if(k===0)s.ad(0,d)
else s.u(0,d,c)}else{k=e.a.j(0,$.p())
if(k!==0)s.u(0,A.eF(j,q,p),e)}}}return s},
dv(a,b){var s,r,q
t.X.a(a)
if(b===0)return A.B([A.X(t.N,t.p),$.u()],t.P,t.G)
s=A.lK(a)
if(b<0||b>128||s>B.c.au(128,b))throw A.c(B.es)
for(r=a,q=1;q<b;++q)r=this.by(r,a)
return r},
ca(a,b){var s,r
t.X.a(a)
t.P.a(b)
for(s=new A.aP(a,a.r,a.e,A.q(a).h("aP<1>"));s.q();){r=s.d
if(this.dh(r,b))return r}return null},
dh(a,b){var s,r=t.P
r.a(a)
r.a(b)
if(a.gB(a)!==b.gB(b))return!1
for(r=a.gaw(),r=r.gC(r);r.q();){s=r.gD()
if(b.m(0,s.a)!==s.b)return!1}return!0}}
A.jL.prototype={
$1(a){return A.K(a)!==0},
$S:2}
A.jK.prototype={
$2(a,b){A.I(a)
return A.K(b)===0},
$S:49}
A.jr.prototype={
k(a){return"EvalException: "+this.a}}
A.ke.prototype={
$1(a){return a<0?-Math.pow(-a,0.3333333333333333):Math.pow(a,0.3333333333333333)},
$S:0}
A.kf.prototype={
$1(a){return Math.log(a)/2.302585092994046},
$S:0}
A.kg.prototype={
$1(a){return Math.log(a)/2.302585092994046},
$S:0}
A.kn.prototype={
$1(a){return Math.log(a)/0.6931471805599453},
$S:0}
A.ko.prototype={
$1(a){return Math.abs(a)},
$S:0}
A.kp.prototype={
$1(a){return(Math.exp(a)-Math.exp(-a))/2},
$S:0}
A.kq.prototype={
$1(a){return(Math.exp(a)+Math.exp(-a))/2},
$S:0}
A.kr.prototype={
$1(a){var s=Math.exp(a),r=Math.exp(-a)
return(s-r)/(s+r)},
$S:0}
A.ks.prototype={
$1(a){return Math.log(a+Math.sqrt(a*a+1))},
$S:0}
A.kt.prototype={
$1(a){return Math.log(a+Math.sqrt(a*a-1))},
$S:0}
A.ku.prototype={
$1(a){return 0.5*Math.log((1+a)/(1-a))},
$S:0}
A.kh.prototype={
$1(a){return Math.floor(a)},
$S:0}
A.ki.prototype={
$1(a){return Math.ceil(a)},
$S:0}
A.kj.prototype={
$1(a){return Math.ceil(a)},
$S:0}
A.kk.prototype={
$1(a){return B.f.b6(a)},
$S:0}
A.kl.prototype={
$1(a){return a<0?Math.ceil(a):Math.floor(a)},
$S:0}
A.km.prototype={
$1(a){return J.aN(a)},
$S:0}
A.es.prototype={
K(a){var s,r
t.U.a(a)
try{s=this.a.$1(a)
return s}catch(r){return null}}}
A.jM.prototype={
bB(){var s,r,q,p,o=this,n=o.bC()
for(s=o.a,r=s.length;;){o.av()
q=o.b
p=q<r?s[q]:null
if(p==="+"){o.b=q+1
n=new A.jN(n,o.bC())}else if(p==="-"){o.b=q+1
n=new A.jO(n,o.bC())}else return n}},
bC(){var s,r,q,p,o=this,n=o.aG()
for(s=o.a,r=s.length;;){o.av()
q=o.b
p=q<r?s[q]:null
if(p==="*"){o.b=q+1
n=new A.jU(n,o.aG())}else if(p==="/"){o.b=q+1
n=new A.jV(n,o.aG())}else if(p==="%"){o.b=q+1
n=new A.jW(n,o.aG())}else if(o.dH(p))n=new A.jX(n,o.aG())
else return n}},
dH(a){if(a==null)return!1
return A.lL(a)||a==="."||a==="("||A.nf(a)},
aG(){var s,r=this
r.av()
s=r.aQ()
if(s==="+"){++r.b
return r.aG()}if(s==="-"){++r.b
return new A.jY(r.aG())}return r.dk()},
dk(){var s=this,r=s.du()
s.av()
if(s.aQ()==="^"){++s.b
return new A.jT(r,s.aG())}return r},
du(){var s,r,q=this
q.av()
s=q.aQ()
if(s==null)throw A.c(A.bZ("unexpected end"))
if(s==="("){++q.b
r=q.bB()
q.av()
if(q.aQ()!==")")throw A.c(A.bZ("expected )"));++q.b
return r}if(A.lL(s)||s===".")return q.dj()
if(A.nf(s))return q.dr()
throw A.c(A.bZ('unexpected "'+s+'"'))},
dj(){var s,r,q,p,o,n,m=this,l=m.b,k=m.a,j=k.length,i=l
for(;;){s=i<j
if(s){r=k[i]
if(0>=r.length)return A.a(r,0)
q=r.charCodeAt(0)
r=q>=48&&q<=57}else r=!1
if(!r)break;++i
m.b=i}if(s&&k[i]==="."){++i
m.b=i
for(;;){if(i<j){s=k[i]
if(0>=s.length)return A.a(s,0)
q=s.charCodeAt(0)
s=q>=48&&q<=57}else s=!1
if(!s)break;++i
m.b=i}}if(i<j){s=k[i]
s=s==="e"||s==="E"}else s=!1
if(s){p=i+1
if(p<j){i=k[p]
i=i==="+"||i==="-"}else i=!1
if(i)++p
if(p<j&&A.lL(k[p])){m.b=p
i=p
for(;;){if(i<j){s=k[i]
if(0>=s.length)return A.a(s,0)
q=s.charCodeAt(0)
s=q>=48&&q<=57}else s=!1
if(!s)break;++i
m.b=i}}}o=B.a.F(k,l,m.b)
n=A.am(o)
if(n==null)throw A.c(A.bZ('bad number "'+o+'"'))
return new A.jS(n)},
dr(){var s,r,q,p,o,n,m,l=this,k=l.b,j=l.a,i=j.length,h=k
for(;;){if(h<i){s=j[h]
if(0>=s.length)return A.a(s,0)
r=s.charCodeAt(0)
if(!(r>=65&&r<=90))q=r>=97&&r<=122||s==="_"
else q=!0
if(!q){r=s.charCodeAt(0)
s=r>=48&&r<=57}else s=!0}else s=!1
if(!s)break;++h
l.b=h}p=B.a.F(j,k,h)
l.av()
if(l.aQ()==="("){o=$.ow().m(0,p)
if(o==null)throw A.c(A.bZ('unknown function "'+p+'"'));++l.b
n=l.bB()
l.av()
if(l.aQ()===",")throw A.c(A.bZ('multi-arg "'+p+'"'))
if(l.aQ()!==")")throw A.c(A.bZ("expected ) after "+p+"("));++l.b
return new A.jP(o,n)}m=B.hE.m(0,p)
if(m!=null)return new A.jQ(m)
return new A.jR(p)},
aQ(){var s=this.b,r=this.a
return s<r.length?r[s]:null},
av(){var s,r=this.a,q=r.length
for(;;){s=this.b
if(!(s<q&&r[s]===" "))break
this.b=s+1}}}
A.jN.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.A()
if(typeof r!=="number")return A.aU(r)
return s+r},
$S:4}
A.jO.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.G()
if(typeof r!=="number")return A.aU(r)
return s-r},
$S:4}
A.jU.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.i()
if(typeof r!=="number")return A.aU(r)
return s*r},
$S:4}
A.jV.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.ac()
if(typeof r!=="number")return A.aU(r)
return s/r},
$S:4}
A.jW.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.W()
if(typeof r!=="number")return A.aU(r)
return B.f.W(s,r)},
$S:4}
A.jX.prototype={
$1(a){var s,r
t.U.a(a)
s=this.a.$1(a)
r=this.b.$1(a)
if(typeof s!=="number")return s.i()
if(typeof r!=="number")return A.aU(r)
return s*r},
$S:4}
A.jY.prototype={
$1(a){return J.kY(this.a.$1(t.U.a(a)))},
$S:4}
A.jT.prototype={
$1(a){t.U.a(a)
return Math.pow(this.a.$1(a),this.b.$1(a))},
$S:4}
A.jS.prototype={
$1(a){t.U.a(a)
return this.a},
$S:4}
A.jP.prototype={
$1(a){return this.a.$1(this.b.$1(t.U.a(a)))},
$S:4}
A.jQ.prototype={
$1(a){t.U.a(a)
return this.a},
$S:4}
A.jR.prototype={
$1(a){var s=this.a,r=t.U.a(a).m(0,s)
if(r!=null)return r
throw A.c(A.bZ('free symbol "'+s+'"'))},
$S:4}
A.i0.prototype={
$0(){var s=this
return new A.aR(!0,A.hZ(s.a,s.b,s.c,s.d),s.e)},
$S:13}
A.i2.prototype={
$0(){var s=this
return new A.aR(!0,s.e,A.hZ(s.a,s.b,s.c,s.d))},
$S:13}
A.i3.prototype={
$0(){var s=this
return new A.aR(!0,A.hZ(s.a,s.b,s.c,s.d),s.e)},
$S:13}
A.i1.prototype={
$0(){var s=this
return new A.aR(!0,s.e,A.hZ(s.a,s.b,s.c,s.d))},
$S:13}
A.i_.prototype={
$2(a,b){return B.b.l(this.a,new A.c0([a.b,b.b,a.c,b.c]))},
$S:34}
A.i4.prototype={
$2(a,b){var s=this.a
return s==null?null:s.K(A.B(["x",a,"y",b],t.N,t.V))},
$S:21}
A.i5.prototype={
$2(a,b){var s=this.a
return s==null?null:s.K(A.B(["x",a,"y",b],t.N,t.V))},
$S:21}
A.f.prototype={
A(a,b){var s=b.b,r=this.b
return A.k(this.a.i(0,s).A(0,b.a.i(0,r)),r.i(0,s))},
G(a,b){var s=b.b,r=this.b
return A.k(this.a.i(0,s).G(0,b.a.i(0,r)),r.i(0,s))},
i(a,b){return A.k(this.a.i(0,b.a),this.b.i(0,b.b))},
ac(a,b){return A.k(this.a.i(0,b.b),this.b.i(0,b.a))},
I(a,b){var s,r
if(b==null)return!1
s=!1
if(b instanceof A.f){r=b.a.j(0,this.a)
if(r===0)s=b.b.j(0,this.b)===0}return s},
gU(a){return A.dv(this.a,this.b,B.i,B.i)},
k(a){var s=this.b,r=s.j(0,$.o()),q=this.a
return r===0?q.k(0):q.k(0)+"/"+s.k(0)}}
A.G.prototype={
gb_(){var s=this.a,r=s.length,q=r-1
if(!(q>=0))return A.a(s,q)
return s[q]},
a_(a){var s,r=a.a.j(0,$.p())
if(r===0)return new A.G(B.h,this.b)
r=this.a
s=A.H(r)
return new A.G(A.cb(new A.t(r,s.h("@(1)").a(new A.ii(a)),s.h("t<1,@>")),t.G),this.b)},
G(a,b){var s,r=this,q=r.a.length,p=q-1,o=b.a.length-1
p=p>o?p:o
if(p<0)return new A.G(B.h,q===0?b.b:r.b)
s=A.la(p+1,new A.ih(r,b),t.G)
return A.cM(s,q===0?b.b:r.b)},
A(a,b){var s,r=this,q=r.a.length,p=q-1,o=b.a.length-1
p=p>o?p:o
if(p<0)return new A.G(B.h,q===0?b.b:r.b)
s=A.la(p+1,new A.ig(r,b),t.G)
return A.cM(s,q===0?b.b:r.b)},
i(a,b){var s,r,q,p,o,n,m,l,k,j,i=this.a,h=i.length,g=h===0
if(g||b.a.length===0)return new A.G(B.h,g?b.b:this.b);--h
g=b.a
s=g.length-1
r=h+s+1
q=A.aA(r,$.J(),!1,t.G)
for(p=0;p<=h;++p)for(o=0;o<=s;++o){n=p+o
if(!(n<r))return A.a(q,n)
m=q[n]
l=i[p]
k=g[o]
k=A.k(l.a.i(0,k.a),l.b.i(0,k.b))
l=k.b
j=m.b
B.b.u(q,n,A.k(m.a.i(0,l).A(0,k.a.i(0,j)),j.i(0,l)))}return A.cM(q,this.b)},
a1(a){var s,r,q
if(a<0)throw A.c(A.aG("negative power",null))
s=A.dw($.u(),this.b)
for(r=a,q=this;r>0;){if((r&1)===1)s=s.i(0,q)
r=B.c.aI(r,1)
if(r>0)q=q.i(0,q)}return s},
ah(){var s,r,q,p,o,n,m=this.a,l=m.length-1
if(l<1)return new A.G(B.h,this.b)
s=J.bg(l,t.G)
for(r=0;r<l;r=q){q=r+1
p=m[q]
o=A.C(q)
n=$.o()
s[r]=A.k(p.a.i(0,o),p.b.i(0,n))}return A.cM(s,this.b)},
aT(){var s=this
if(s.a.length===0)return s
return s.a_($.u().ac(0,s.gb_()))},
Y(a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=a2.a,a1=a0.length
if(a1===0)throw A.c(A.aG("division by the zero polynomial",null))
s=a.a
r=s.length-1
q=a1-1
if(r<q)return new A.cY(new A.G(B.h,a.b),a)
p=t.G
o=A.bh(s,!0,p)
n=a2.gb_()
m=A.aA(r-q+1,$.J(),!1,p)
for(s=n.b,p=n.a;r>=q;--r){if(!(r>=0&&r<o.length))return A.a(o,r)
l=o[r]
k=l.a
j=k.j(0,$.p())
if(j===0)continue
i=A.k(k.i(0,s),l.b.i(0,p))
k=r-q
B.b.u(m,k,i)
for(j=i.a,h=i.b,g=0;g<=q;++g){f=k+g
if(!(f>=0&&f<o.length))return A.a(o,f)
e=o[f]
if(!(g<a1))return A.a(a0,g)
d=a0[g]
d=A.k(j.i(0,d.a),h.i(0,d.b))
c=d.b
b=e.b
B.b.u(o,f,A.k(e.a.i(0,c).G(0,d.a.i(0,b)),b.i(0,c)))}}a0=a.b
return new A.cY(A.cM(m,a0),A.cM(o,a0))},
k(a){var s,r,q,p,o,n,m,l,k,j,i=this.a,h=i.length
if(h===0)return"0"
s=new A.bm("")
for(r=h-1,h=this.b;r>=0;--r){q=i[r]
p=q.a
o=p.j(0,$.p())
if(o===0)continue
o=p.a?p.n(0):p
n=q.b
m=s.a
if(m.length===0)if(p.gE(0)<0){p=m+"-"
s.a=p}else p=m
else{m+=p.gE(0)<0?" - ":" + "
s.a=m
p=m}if(r!==0){m=$.u()
l=!1
k=m.a.j(0,o)
if(k===0)m=m.b.j(0,n)===0
else m=l
j=!m}else j=!0
if(j){m=n.j(0,$.o())
p=s.a=p+(m===0?o.k(0):o.k(0)+"/"+n.k(0))}if(r>=1){p+=h
s.a=p
if(r>1)s.a=p+("^"+r)}}i=s.a
return i.charCodeAt(0)==0?i:i}}
A.ij.prototype={
$2(a,b){A.K(a)
A.K(b)
return a>b?a:b},
$S:8}
A.ii.prototype={
$1(a){return t.G.a(a).i(0,this.a)},
$S:16}
A.ih.prototype={
$1(a){var s=this.a.a,r=a<=s.length-1?s[a]:$.J()
s=this.b.a
return r.G(0,a<=s.length-1?s[a]:$.J())},
$S:18}
A.ig.prototype={
$1(a){var s=this.a.a,r=a<=s.length-1?s[a]:$.J()
s=this.b.a
return r.A(0,a<=s.length-1?s[a]:$.J())},
$S:18}
A.i6.prototype={
$1(a){return A.lj(t.G.a(a).ac(0,this.a.a.gb_()))},
$S:16}
A.i7.prototype={
$1(a){var s,r,q,p,o,n,m=0,l=0
for(q=this.a,p=q.length,o=0;o<q.length;q.length===p||(0,A.M)(q),++o){s=q[o]
r=A.lk(s,a).a.gE(0)
if(J.N(r,0))continue
if(!J.N(m,0)&&!J.N(r,m)){n=l
if(typeof n!=="number")return n.A()
l=n+1}m=r}return l},
$S:56}
A.i9.prototype={
$1(a){var s=t.bv.a(a).b
return s.a.gt(0)>4096||s.b.gt(0)>4096},
$S:57}
A.i8.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g=A.X(t.N,t.G)
for(s=a.gae(),r=s.$ti,s=new A.af(s.a(),r.h("af<1>")),q=this.a,p=a.a,o=t.t,r=r.c;s.q();){n=s.b
if(n==null)n=r.a(n)
m=n.a
l=n.b
n=A.d([],o)
for(k=q.length,j=J.aj(m),i=0;i<q.length;q.length===k||(0,A.M)(q),++i){h=q[i]
n.push(B.b.J(p,h)?j.m(m,B.b.ao(p,h)):0)}g.u(0,B.b.H(n,","),l)}return g},
$S:58}
A.ic.prototype={
$1(a){var s=t.x
s=A.L(new A.t(A.d(a.split(","),t.s),t.v.a(A.cx()),s),s.h("D.E"))
return s},
$S:59}
A.id.prototype={
$1(a){t.d0.a(a)
return new A.at(a,A.q(a).h("at<1>")).cE(0,new A.ie(this.a))},
$S:60}
A.ie.prototype={
$2(a,b){var s,r,q,p,o
A.I(a)
A.I(b)
s=this.a
r=s.$1(a)
q=s.$1(b)
for(s=J.aj(r),p=J.aj(q),o=0;o<s.gB(r);++o)if(s.m(r,o)!==p.m(q,o))return s.m(r,o)>p.m(q,o)?a:b
return a},
$S:32}
A.ia.prototype={
$1(a){return A.cZ(a)},
$S:62}
A.ib.prototype={
$1(a){return A.K(a)===0},
$S:2}
A.ik.prototype={}
A.il.prototype={
$1(a){var s=t.F.a(a).b
if(0>=s.length)return A.a(s,0)
s=s[0]
s.toString
return s},
$S:63}
A.im.prototype={
$1(a){return A.bj(A.d([a],t.j),this.a)},
$S:64}
A.io.prototype={
$2(a,b){if(a.a.length-1+(b.a.length-1)>8||A.iq(a)+A.iq(b)>16384)throw A.c(B.R)
return a.i(0,b)},
$S:65}
A.ip.prototype={
$2(a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this
if(a2<=32){f=a0.a.a+1
a0.a.a=f
e=f>256}else e=!0
if(e)throw A.c(B.eh)
if(a1 instanceof A.v)return new A.R(a0.b.$1(a1.a),a0.b.$1($.u()))
if(a1 instanceof A.an&&a1.a===a0.c){e=$.J()
d=$.u()
return new A.R(A.bj(A.d([e,d],t.j),a0.c),a0.b.$1(d))}e=a1 instanceof A.ay
if(e||a1 instanceof A.a_){d=a0.b
s=d.$1(e?$.J():$.u())
r=a0.b.$1($.u())
q=e?a1.a:t.eb.a(a1).a
for(d=q,c=d.length,b=a2+1,a=0;a<d.length;d.length===c||(0,A.M)(d),++a){p=d[a]
o=null
n=null
m=a0.$2(p,b)
o=m.a
n=m.b
s=e?J.oy(a0.d.$2(s,n),a0.d.$2(o,r)):a0.d.$2(s,o)
r=a0.d.$2(r,n)}return new A.R(s,r)}if(a1 instanceof A.a7){l=A.aX(A.bN(a1.b))
k=l==null?null:A.jh(l,null)
if(k!=null){e=k
if(e.a)e=e.n(0)
e=e.j(0,A.C(8))>0}else e=!0
if(e)throw A.c(B.ep)
j=null
i=null
h=a0.$2(a1.a,a2+1)
j=h.a
i=h.b
g=k.ai(0)
if((j.a.length-1)*J.d6(g)>8||(i.a.length-1)*J.d6(g)>8||A.iq(j)*J.d6(g)>16384||A.iq(i)*J.d6(g)>16384)throw A.c(B.R)
e=g
if(typeof e!=="number")return e.af()
if(e<0){B.b.l(a0.e,j)
return new A.R(i.a1(J.kY(g)),j.a1(J.kY(g)))}return new A.R(j.a1(g),i.a1(g))}throw A.c(B.e7)},
$S:66}
A.is.prototype={
$1(a){return t.aD.a(a).a.length-1>=3},
$S:67}
A.it.prototype={
$1(a){return t.G.a(a).i(0,A.k(this.a.a,$.o())).a},
$S:68}
A.iu.prototype={
$1(a){return A.I(a).length!==0},
$S:11}
A.k2.prototype={
bf(a,b){var s=this.b
if(s.length===0)B.b.l(s,b?"-"+a:a)
else B.b.l(s,b?"- "+a:"+ "+a)},
cs(a0){var s,r,q,p,o,n,m,l,k,j,i,h=this.b,g=this.a,f=g+"^",e=a0.a,d=e.length,c=d-1,b=d!==0,a=0
for(;;){if(!(a<=c&&b))break
A:{if(!(a<d))return A.a(e,a)
s=e[a]
r=s.a
q=r.j(0,$.p())
if(q===0)break A
q=a+1
p=A.C(q)
o=$.o()
n=A.k(r.i(0,o),s.b.i(0,p))
p=n.a
r=p.a?p.n(0):p
m=n.b
l=a===0?g:f+q
q=$.u()
k=!1
j=q.a.j(0,r)
if(j===0)q=q.b.j(0,m)===0
else q=k
if(q)i=l
else{q=m.j(0,o)
i=(q===0?r.k(0):r.k(0)+"/"+m.k(0))+"*"+l}r=p.gE(0)<0
if(h.length===0)B.b.l(h,r?"-"+i:i)
else B.b.l(h,r?"- "+i:"+ "+i)}++a}},
dQ(a,b,c){var s,r,q,p,o=a.a,n=o.length
if(n===0)return
if(n-1===0){if(0>=n)return A.a(o,0)
s=o[0].a.gE(0)<0}else s=!1
r=s?a.a_(new A.f(A.C(-1),$.o())):a
o=r.a
n=o.length
if(n-1===0){if(0>=n)return A.a(o,0)
q=A.fg(o[0])}else q="("+A.bq(r)+")"
p=c===1?"("+A.bq(b)+")":"("+A.bq(b)+")^"+c
this.bf(q+"/"+p,s)},
bJ(a,b){var s,r,q,p=a.a,o=p.j(0,$.p())
if(o===0)return
o=p.a?p.n(0):p
s=new A.f(o,a.b)
r="log("+A.bq(b)+")"
q=s.I(0,$.u())?r:A.fg(s)+"*"+r
this.bf(q,p.gE(0)<0)},
dP(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=a.a,f=g.length
if(f-1>=1){if(1>=f)return A.a(g,1)
s=g[1]}else s=$.J()
if(f!==0){if(0>=f)return A.a(g,0)
r=g[0]}else r=$.J()
g=b.a
if(1>=g.length)return A.a(g,1)
q=g[1]
p=g[0]
g=$.o()
o=A.k(g,$.bO())
this.bJ(s.i(0,o),b)
n=r.G(0,s.i(0,q).i(0,o))
f=n.a
m=f.j(0,$.p())
if(m===0)return
l=q.i(0,q).G(0,new A.f(A.C(4),g).i(0,p))
k="("+A.bq(A.bj(A.d([q,new A.f(A.C(2),g)],t.j),b.b))+")"
m=l.a
if(m.gE(0)<0){j=A.nn(new A.f(m.n(0),l.b))
i=n.i(0,new A.f(A.C(2),g))
g=i.a
f=g.a?g.n(0):g
h=new A.f(f,i.b)
f=h.I(0,$.u())?"1/"+j+"*":A.fg(h)+"/"+j+"*"
this.bf(f+"atan("+k+"/"+j+")",g.gE(0)<0)}else{j=A.nn(l)
g=f.a?f.n(0):f
h=new A.f(g,n.b)
g=h.I(0,$.u())?"1/"+j+"*":A.fg(h)+"/"+j+"*"
this.bf(g+"log(("+k+" - "+j+")/("+k+" + "+j+"))",f.gE(0)<0)}}}
A.iv.prototype={
$1(a){return A.r(a.m(0,1))+"*"+A.r(a.m(0,2))},
$S:12}
A.iA.prototype={
$1(a){var s
if(a.m(0,0)===this.a)s="("+this.b+")"
else{s=a.m(0,0)
s.toString}return s},
$S:12}
A.iB.prototype={
$1(a){var s,r,q,p,o=this,n=o.a.b
if(2>=n.length)return A.a(n,2)
s=n[2]
if(s==="ln"||s==="log"){if(a===0)return 0
r=Math.log(a)
for(n=o.b,q=a,p=1;p<=n;++p)q=a*Math.pow(r,p)-p*q
return q/o.c}s=o.c
return n[1]==null?2*a*Math.sqrt(a)/(3*s):2*Math.sqrt(a)/s},
$S:0}
A.iw.prototype={
$1(a){var s,r,q,p=A.aX(a)
if(p==null)return null
s=p.split("/")
r=s.length
if(0>=r)return A.a(s,0)
q=A.ae(s[0],null)
if(r===1)r=$.o()
else{if(1>=r)return A.a(s,1)
r=A.ae(s[1],null)}return A.k(q,r)},
$S:69}
A.iy.prototype={
$1(a){var s=Math.max(0,a.gt(0)-53)
return Math.log(a.ak(0,s).aB(0))+s*0.6931471805599453},
$S:70}
A.iz.prototype={
$1(a){var s,r,q,p,o,n,m,l=a.a,k=a.b,j=l.G(0,k),i=j.j(0,$.p())
if(i===0)return 0
i=j.a
s=i?j.n(0):j
if(s.i(0,A.C(8)).j(0,k)<=0){r=j.aB(0)/k.aB(0)
if(!isFinite(r)||r===0){l=this.a
s=l.$1(i?j.n(0):j)
k=l.$1(k)
if(typeof s!=="number")return s.G()
if(typeof k!=="number")return A.aU(k)
r=Math.exp(s-k)*j.gE(0)}if(!isFinite(r)||r===0)return null
for(l=-r,q=r,p=q,o=2;o<=32;++o,q=n){p*=l
n=q+p/o
if(n===q)break}return q}m=l.aB(0)/k.aB(0)
if(isFinite(m)&&m>0)return Math.log(m)
i=this.a
l=i.$1(l)
k=i.$1(k)
if(typeof l!=="number")return l.G()
if(typeof k!=="number")return A.aU(k)
return l-k},
$S:71}
A.ix.prototype={
$2(a,b){return a.gt(0)+b.gt(0)<=32768},
$S:92}
A.ch.prototype={
aX(){return"ResultAccuracy."+this.b}}
A.aW.prototype={
aX(){return"ComputationMethod."+this.b}}
A.ax.prototype={
b0(){var s,r=this,q=A.X(t.N,t.z)
q.u(0,"accuracy",r.a.b)
q.u(0,"method",r.b.b)
if(r.c)q.u(0,"unchanged",!0)
s=r.d
if(s!=null)q.u(0,"sourceDomain",s)
return q}}
A.fP.prototype={
b0(){var s,r=A.X(t.N,t.z)
r.u(0,"value",this.a)
s=this.b
if(s!=null)r.u(0,"evidence",s.b0())
return r}}
A.a1.prototype={}
A.iL.prototype={
$1(a){t.dT.a(a)
return a.a+"\u222b "+a.b+" d"+this.a},
$S:73}
A.iE.prototype={
$1(a){var s,r
t.gM.a(a)
s=a.b
r=""+a.a
return s>1?r+" (\xd7"+s+")":r},
$S:74}
A.iG.prototype={
$1(a){return"-cos("+a+")"},
$S:5}
A.iH.prototype={
$1(a){return"sin("+a+")"},
$S:5}
A.iI.prototype={
$1(a){return"exp("+a+")"},
$S:5}
A.iJ.prototype={
$1(a){return"cosh("+a+")"},
$S:5}
A.iK.prototype={
$1(a){return"sinh("+a+")"},
$S:5}
A.bK.prototype={}
A.jm.prototype={}
A.jt.prototype={}
A.fb.prototype={}
A.be.prototype={
aX(){return"ExpressionProblem."+this.b}}
A.cF.prototype={
k(a){var s=this.b
s=s==null?"":", "+s
return"ExpressionDiagnosis("+this.a.b+s+")"}}
A.k7.prototype={
$1(a){return t.gY.a(a).a},
$S:76}
A.E.prototype={}
A.v.prototype={
V(){return this},
gab(){var s=this.a
return"n:"+s.a.k(0)+"/"+s.b.k(0)},
gaa(){return 0}}
A.an.prototype={
V(){return this},
gab(){return"s:"+this.a},
gaa(){return 1}}
A.ay.prototype={
V(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=t.h,b=A.d([],c),a=new A.iN(b)
for(s=this.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.M)(s),++q)a.$1(s[q])
p=$.J()
s=t.N
o=A.X(s,t.G)
n=A.X(s,t.i)
for(s=b.length,q=0;q<b.length;b.length===s||(0,A.M)(b),++q){m=A.nV(b[q])
l=m.a
k=m.b
if(k==null){r=l.b
j=p.b
p=A.k(p.a.i(0,r).A(0,l.a.i(0,j)),j.i(0,r))
continue}i=k.gab()
r=o.m(0,i)
if(r==null)r=$.J()
j=l.b
h=r.b
o.u(0,i,A.k(r.a.i(0,j).A(0,l.a.i(0,h)),h.i(0,j)))
n.u(0,i,k)}g=A.d([],c)
for(s=new A.O(o,o.$ti.h("O<1,2>")).gC(0);s.q();){f=s.d
r=f.b
j=r.a
h=j.j(0,$.p())
if(h===0)continue
h=n.m(0,f.a)
h.toString
e=$.u()
d=!1
j=e.a.j(0,j)
if(j===0)j=e.b.j(0,r.b)===0
else j=d
if(j)r=h
else r=new A.a_(A.d([new A.v(r),h],c)).V()
B.b.l(g,r)}c=p.a.j(0,$.p())
if(c!==0)B.b.l(g,new A.v(p))
c=g.length
if(c===0)return $.fm()
if(c===1)return B.b.gP(g)
B.b.aW(g,A.m1())
return new A.ay(g)},
gab(){var s=this.a,r=A.H(s),q=r.h("t<1,i>")
s=A.L(new A.t(s,r.h("i(1)").a(new A.iM()),q),q.h("D.E"))
B.b.aV(s)
return"add:"+B.b.H(s,",")},
gaa(){return B.b.aA(this.a,0,new A.iO(),t.p)}}
A.iN.prototype={
$1(a){var s,r,q,p=a.V()
if(p instanceof A.ay)for(s=p.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.M)(s),++q)this.$1(s[q])
else B.b.l(this.a,p)},
$S:23}
A.iM.prototype={
$1(a){return t.i.a(a).gab()},
$S:10}
A.iO.prototype={
$2(a,b){A.K(a)
t.i.a(b)
return b.gaa()>a?b.gaa():a},
$S:15}
A.a_.prototype={
V(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=t.h,b=A.d([],c),a=new A.iT(b)
for(s=this.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.M)(s),++q)a.$1(s[q])
p=$.u()
s=t.N
r=t.i
o=A.X(s,r)
n=A.X(s,r)
for(s=b.length,q=0;q<b.length;b.length===s||(0,A.M)(b),++q){m=b[q]
if(m instanceof A.v){r=m.a
p=A.k(p.a.i(0,r.a),p.b.i(0,r.b))
continue}l=A.rZ(m)
k=l.a
j=l.b
i=k.gab()
if(o.a8(i)){r=o.m(0,i)
r.toString
r=new A.ay(A.d([r,j],c)).V()}else r=j
o.u(0,i,r)
n.u(0,i,k)}s=p.a.j(0,$.p())
if(s===0)return $.fm()
h=A.d([],c)
for(c=new A.O(o,o.$ti.h("O<1,2>")).gC(0);c.q();){g=c.d
j=g.b
s=j instanceof A.v
if(s)r=j.a.a.j(0,$.p())===0
else r=!1
if(r)continue
r=n.m(0,g.a)
r.toString
f=!1
if(s){s=j.a
e=$.u()
d=e.a.j(0,s.a)
if(d===0)s=e.b.j(0,s.b)===0
else s=f}else s=f
if(s)s=r
else s=new A.a7(r,j)
B.b.l(h,s)}if(h.length===0)return new A.v(p)
if(!p.I(0,$.u()))B.b.e5(h,0,new A.v(p))
if(h.length===1)return B.b.gP(h)
return new A.a_(h)},
gab(){var s=this.a,r=A.H(s),q=r.h("t<1,i>")
s=A.L(new A.t(s,r.h("i(1)").a(new A.iS()),q),q.h("D.E"))
B.b.aV(s)
return"mul:"+B.b.H(s,",")},
gaa(){return B.b.aA(this.a,0,new A.iU(),t.p)}}
A.iT.prototype={
$1(a){var s,r,q,p=a.V()
if(p instanceof A.a_)for(s=p.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.M)(s),++q)this.$1(s[q])
else B.b.l(this.a,p)},
$S:23}
A.iS.prototype={
$1(a){return t.i.a(a).gab()},
$S:10}
A.iU.prototype={
$2(a,b){return A.K(a)+t.i.a(b).gaa()},
$S:15}
A.a7.prototype={
V(){var s,r,q,p,o,n=this.a.V(),m=this.b.V()
if(m instanceof A.v){s=m.a
r=s.a
q=$.p()
p=r.j(0,q)
if(p===0)return $.ej()
if(s.I(0,$.u()))return n
if(n instanceof A.v){p=n.a
q=p.a.j(0,q)
if(q===0&&r.gE(0)<0)throw A.c(B.hX)
o=A.rN(p,s)
if(o!=null)return new A.v(o)}if(n instanceof A.a7)r=s.b.j(0,$.o())===0
else r=!1
if(r)return new A.a7(n.a,new A.a_(A.d([n.b,m],t.h)).V()).V()
if(n instanceof A.a_)s=s.b.j(0,$.o())===0
else s=!1
if(s){s=n.a
r=A.H(s)
q=r.h("t<1,E>")
s=A.L(new A.t(s,r.h("E(1)").a(new A.iV(m)),q),q.h("D.E"))
return new A.a_(s).V()}}if(n instanceof A.v&&n.a.I(0,$.u()))return $.ej()
return new A.a7(n,m)},
gab(){return"pow:"+this.a.gab()+"^"+this.b.gab()},
gaa(){var s,r,q=this.b
if(q instanceof A.v)s=q.a.b.j(0,$.o())===0
else s=!1
if(s){r=q.a.a.ai(0)
s=this.a.gaa()
return s*(r>0?r:0)}return this.a.gaa()}}
A.iV.prototype={
$1(a){return new A.a7(t.i.a(a),this.a).V()},
$S:9}
A.aE.prototype={
V(){var s,r=this.b,q=A.H(r),p=q.h("t<1,E>"),o=A.L(new A.t(r,q.h("E(1)").a(new A.iQ()),p),p.h("D.E"))
r=this.a
s=A.rl(r,o)
if(s!=null)return s
return new A.aE(r,o)},
gab(){var s=this.b,r=A.H(s)
return"call:"+this.a+"("+new A.t(s,r.h("i(1)").a(new A.iP()),r.h("t<1,i>")).H(0,",")+")"},
gaa(){return B.b.aA(this.b,0,new A.iR(),t.p)}}
A.iQ.prototype={
$1(a){return t.i.a(a).V()},
$S:9}
A.iP.prototype={
$1(a){return t.i.a(a).gab()},
$S:10}
A.iR.prototype={
$2(a,b){A.K(a)
t.i.a(b)
return b.gaa()>a?b.gaa():a},
$S:15}
A.bD.prototype={
k(a){return"SymbolicException("+this.a.b+")"}}
A.kb.prototype={
$1(a){return t.i.a(a) instanceof A.v},
$S:28}
A.kc.prototype={
$1(a){return t.w.a(t.i.a(a)).a},
$S:80}
A.kd.prototype={
$1(a){var s=a.b.j(0,$.o())
return s===0?a.a:null},
$S:81}
A.k9.prototype={
$1(a){var s,r,q=$.o()
if(a.j(0,q)<0)return null
for(s=this.a,r=0;q.j(0,a)<0;){q=q.i(0,s);++r
if(r>4096)return null}return q.I(0,a)?A.C(r):null},
$S:82}
A.kw.prototype={
$1(a){var s,r,q,p,o,n
t.i.a(a)
if(a instanceof A.v)return!0
if(a instanceof A.an){s=this.a
r=a.a
q=s.m(0,r)
s.u(0,r,(q==null?0:q)+1)
return!0}if(a instanceof A.a_)return B.b.az(a.a,this)
if(a instanceof A.a7){p=a.a
o=a.b
s=!0
if(p instanceof A.an)if(o instanceof A.v){s=o.a.b.j(0,$.o())
s=s!==0}if(s)return!1
n=o.a.a.ai(0)
s=this.a
r=p.a
q=s.m(0,r)
s.u(0,r,(q==null?0:q)+n)
return!0}return!1},
$S:28}
A.bW.prototype={
aN(){var s,r,q,p,o=this
o.a5()
s=o.a
r=s.length
if(o.b>=r)throw A.c(B.j)
q=o.bH()
o.a5()
p=o.b
if(p<r){if(s[p]===")")throw A.c(B.a2)
throw A.c(B.p)}return q},
bH(){var s,r,q,p,o,n,m,l=this,k=l.co()
for(s=t.h,r=l.a,q=r.length;;){l.a5()
p=l.b
o=p<q?r[p]:null
n=o==="+"
if(!n&&o!=="-")break
l.b=p+1
l.a5()
if(l.b>=q)throw A.c(B.j)
m=l.co()
k=n?new A.ay(A.d([k,m],s)):new A.ay(A.d([k,new A.a_(A.d([new A.v(new A.f(A.C(-1),$.o())),m],s))],s))}return k},
co(){var s,r,q,p,o,n,m,l=this,k=l.aY()
for(s=t.h,r=l.a,q=r.length;;){l.a5()
p=l.b
o=p<q?r[p]:null
n=o==="*"
if(n||o==="/"){l.b=p+1
l.a5()
if(l.b>=q)throw A.c(B.j)
m=l.aY()
k=n?new A.a_(A.d([k,m],s)):new A.a_(A.d([k,new A.a7(m,new A.v(new A.f(A.C(-1),$.o())))],s))
continue}if(l.dM(o)){k=new A.a_(A.d([k,l.aY()],s))
continue}break}return k},
dM(a){if(a==null)return!1
return A.lq(a)||A.mU(a)||a==="("},
aY(){var s,r=this
r.a5()
s=r.bi()
if(s==="-"){++r.b
return new A.a_(A.d([new A.v(new A.f(A.C(-1),$.o())),r.aY()],t.h))}if(s==="+"){++r.b
return r.aY()}return r.dK()},
dK(){var s=this,r=s.dt()
s.a5()
if(s.bi()==="^"){++s.b
s.a5()
if(s.b>=s.a.length)throw A.c(B.j)
return new A.a7(r,s.aY())}return r},
dt(){var s,r,q,p,o=this,n=o.dL()
for(s=t.h,r=o.a,q=r.length;;){o.a5()
p=o.b
if((p<q?r[p]:null)==="!"){o.b=p+1
n=new A.aE("factorial",A.d([n],s))
continue}break}return n},
dL(){var s,r,q,p,o,n=this
n.a5()
s=n.b
r=n.a
q=r.length
if(s>=q)throw A.c(B.j)
p=r[s]
if(p==="("){n.b=s+1
n.a5()
if(n.b>=q)throw A.c(B.j)
o=n.bH()
n.a5()
s=n.b
if(s>=q)throw A.c(B.j)
if(r[s]!==")")throw A.c(B.p)
n.b=s+1
return o}if(p===")")throw A.c(B.a2)
if(A.lq(p)||p===".")return n.dJ()
if(A.mU(p))return n.dI()
throw A.c(B.p)},
dJ(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.b
for(s=i.a,r=s.length,q=h,p=!1;o=q<r,o;){n=s[q]
if(0>=n.length)return A.a(n,0)
m=n.charCodeAt(0)
if(m>=48&&m<=57){++q
i.b=q}else{if(n==="."){if(p)throw A.c(B.p);++q
i.b=q}else break
p=!0}}if(o){o=s[q]
o=o==="e"||o==="E"}else o=!1
if(o){l=q+1
if(l<r){o=s[l]
o=o==="+"||o==="-"}else o=!1
if(o)++l
if(l<r&&A.lq(s[l])){for(;;){if(l<r){q=s[l]
if(0>=q.length)return A.a(q,0)
m=q.charCodeAt(0)
q=m>=48&&m<=57}else q=!1
if(!q)break;++l}i.b=l
r=l}else{i.b=q
r=q}}else r=q
k=B.a.F(s,h,r)
if(k==="."||k.length===0)throw A.c(B.j)
j=A.rO(k)
if(j==null)throw A.c(B.p)
return new A.v(j)},
dI(){var s,r,q,p,o,n,m=this,l=m.b,k=m.a,j=k.length,i=l
for(;;){if(i<j){s=k[i]
if(0>=s.length)return A.a(s,0)
r=s.charCodeAt(0)
if(!(r>=65&&r<=90))q=r>=97&&r<=122||s==="_"
else q=!0
if(!q){r=s.charCodeAt(0)
s=r>=48&&r<=57}else s=!0}else s=!1
if(!s)break;++i
m.b=i}p=B.a.F(k,l,i)
m.a5()
if(m.bi()!=="(")return new A.an(p);++m.b
o=A.d([],t.h)
m.a5()
if(m.b>=j)throw A.c(B.j)
if(m.bi()===")")++m.b
else for(;;){B.b.l(o,m.bH())
m.a5()
i=m.b
if(i>=j)throw A.c(B.j)
s=i<j
if((s?k[i]:null)===","){m.b=i+1
m.a5()
if(m.b>=j)throw A.c(B.j)
continue}if((s?k[i]:null)===")"){m.b=i+1
break}throw A.c(B.p)}n=B.W.m(0,p)
if(n==null)throw A.c(A.iW($.ou().J(0,p)?B.e4:B.e3,p))
if(!n.J(0,o.length))throw A.c(A.iW(B.e6,p))
return new A.aE(p,o)},
bi(){var s=this.b,r=this.a
return s<r.length?r[s]:null},
a5(){var s,r,q=this.a,p=q.length
for(;;){s=this.b
if(s<p){r=q[s]
r=r===" "||r==="\t"}else r=!1
if(!r)break
this.b=s+1}}}
A.ao.prototype={}
A.k_.prototype={}
A.cp.prototype={
aX(){return"_GrowthKind."+this.b}}
A.b9.prototype={}
A.kM.prototype={
$1(a){var s=t.F.a(a).b
if(0>=s.length)return A.a(s,0)
return s[0]!==this.a},
$S:17}
A.kV.prototype={
$1(a){if(A.lY(a))throw A.c(A.dd("not expandable at this point: "+a,null))
return a},
$S:5}
A.j2.prototype={
$1(a){var s,r,q,p,o,n,m,l,k=$.J()
for(s=this.a,r=s.length-1,q=a.a,p=a.b;r>=0;--r){o=A.k(k.a.i(0,q),k.b.i(0,p))
if(!(r<s.length))return A.a(s,r)
n=s[r]
m=n.b
l=o.b
k=A.k(o.a.i(0,m).A(0,n.a.i(0,l)),l.i(0,m))}return k},
$S:16}
A.j3.prototype={
$2(a,b){var s=t.cX
return s.a(a).b.G(0,s.a(b).b).a.gE(0)},
$S:83}
A.j0.prototype={
$1(a){var s=t.Z.a(a).j(0,$.p())
return s!==0},
$S:24}
A.j_.prototype={
$1(a){var s=a.a,r=s.j(0,$.p())
if(r===0)return this.a
if(s.gE(0)<0)return"("+this.a+" + "+new A.f(s.n(0),a.b).k(0)+")"
return"("+this.a+" - "+a.k(0)+")"},
$S:84}
A.aq.prototype={}
A.jZ.prototype={
b2(a){var s,r,q,p,o,n,m,l
for(s=a.a,r=s.length,q=0,p=0,o=0;o<r;++o){n=s[o]
m=n.a
l=(m.a?m.n(0):m).gt(0)
if(l>q)q=l
p+=n.b.gt(0)}return q+p+B.c.gt(r)},
gaR(){var s=this.b,r=this.a
return s<r.length?r[s]:null},
cB(){var s=this,r=++s.d
if(r>500){s.d=r-1
throw A.c(new A.aq())}try{r=s.dq()
return r}finally{--s.d}},
dq(){var s,r,q,p,o,n,m=this
if(m.gaR()==="+"){++m.b
s=!1}else{s=m.gaR()==="-"
if(s)++m.b}r=m.bI()
if(s)r=r.a_(new A.f(A.C(-1),$.o()))
for(q=m.a,p=q.length;;){o=m.b
n=o<p?q[o]:null
if(n==="+"){m.b=o+1
r=r.A(0,m.bI())}else if(n==="-"){m.b=o+1
r=r.G(0,m.bI())}else return r}},
bI(){var s,r,q,p,o,n,m,l=this,k=l.bd()
for(s=l.a,r=s.length;;){q=l.b
p=q<r?s[q]:null
if(p==="*"){l.b=q+1
k=l.ce(k,l.bd())}else if(p==="/"){l.b=q+1
o=l.bd()
q=o.a
n=q.length
if(n-1!==0||n===0)throw A.c(new A.aq())
if(l.b2(k)+l.b2(o)>16384)throw A.c(new A.aq())
m=$.u()
if(0>=n)return A.a(q,0)
q=q[0]
k=k.a_(A.k(m.a.i(0,q.b),m.b.i(0,q.a)))}else if(l.dG(p))k=l.ce(k,l.bd())
else return k}},
ce(a,b){if(a.a.length-1+(b.a.length-1)>256||this.b2(a)+this.b2(b)>16384)throw A.c(new A.aq())
return a.i(0,b)},
dG(a){if(a==null)return!1
return A.nl(a)||a==="."||a==="("||A.lM(a)},
bd(){var s,r,q=this,p=q.dm()
if(q.gaR()==="^"){++q.b
s=q.ci()
if(s<=256)r=s>0&&p.a.length-1>B.c.au(256,s)||q.b2(p)*s>16384
else r=!0
if(r)throw A.c(new A.aq())
p=p.a1(s)}return p},
dm(){var s,r,q,p,o=this,n=o.gaR()
if(n==null)throw A.c(new A.aq())
if(n==="("){++o.b
s=o.cB()
if(o.gaR()!==")")throw A.c(new A.aq());++o.b
return s}if(A.nl(n)||n===".")return o.dN()
if(A.lM(n)){r=o.a
q=o.b
p=r.length
if(!(q<p))return A.a(r,q)
n=r[q];++q
if(q<p&&A.lM(r[q]))A.x(new A.aq());++o.b
r=o.c
q=r==null
if(!q&&r!==n)A.x(new A.aq())
if(q)o.c=n
return new A.G(A.cb([$.J(),$.u()],t.G),n)}throw A.c(new A.aq())},
dN(){var s,r,q,p,o=this,n=o.b,m=o.a,l=m.length,k=n
for(;;){s=k<l
if(s){r=m[k]
if(0>=r.length)return A.a(r,0)
q=r.charCodeAt(0)
r=q>=48&&q<=57}else r=!1
if(!r)break;++k
o.b=k}if(s&&m[k]==="."){++k
o.b=k
for(;;){if(k<l){s=m[k]
if(0>=s.length)return A.a(s,0)
q=s.charCodeAt(0)
s=q>=48&&q<=57}else s=!1
if(!s)break;++k
o.b=k}l=k}else l=k
p=A.nm(B.a.F(m,n,l))
if(p==null)throw A.c(new A.aq())
m=o.c
return A.dw(p,m==null?"x":m)},
ci(){var s,r,q,p,o,n,m,l=this
if(l.gaR()==="("){r=++l.d
if(r>500){l.d=r-1
throw A.c(new A.aq())}++l.b
s=null
try{s=l.ci()}finally{--l.d}if(l.gaR()!==")")throw A.c(new A.aq());++l.b
return s}q=l.b
r=l.a
p=r.length
o=q
for(;;){if(o<p){n=r[o]
if(0>=n.length)return A.a(n,0)
m=n.charCodeAt(0)
n=m>=48&&m<=57}else n=!1
if(!n)break;++o
l.b=o}if(o===q)throw A.c(new A.aq())
s=A.bk(B.a.F(r,q,o),null)
if(s==null)throw A.c(new A.aq())
return s}}
A.kP.prototype={
$1(a){return B.a.p(A.I(a))},
$S:5}
A.kQ.prototype={
$1(a){return B.a.p(A.I(a))},
$S:5}
A.ew.prototype={}
A.kJ.prototype={
$2(a,b){t.U.a(b)
return A.am(this.a.e0(A.kU(a,A.l("\\b[A-Za-z_][A-Za-z_0-9]*\\b",!0),t.A.a(t.I.a(new A.kK(b))),null)))},
$S:85}
A.kK.prototype={
$1(a){var s=this.a
if(s.a8(a.m(0,0)))s="("+A.r(s.m(0,a.m(0,0)))+")"
else{s=a.m(0,0)
s.toString}return s},
$S:12}
A.kI.prototype={
$1(a){var s,r,q,p,o,n,m=this,l=t.r,k=t.N,j=t.z,i=l.a(A.o_(A.cv(t.aX.a(a).data))).bk(0,k,j),h=i,g=l.a(h.$ti.h("4?").a(h.a.m(0,"payload"))).bk(0,k,j)
try{s=null
l=i
switch(l.$ti.h("4?").a(l.a.m(0,"type"))){case"graph":s=A.tL(g,m.a).b0()
break
case"values":s=A.tM(g,m.a)
break
case"surface":s=A.tN(g,m.a)
break
case"engine":l=g
h=g
q=g
p=g
o=g
s=A.o9(m.b,new A.ew(A.I(l.$ti.h("4?").a(l.a.m(0,"kind"))),A.I(h.$ti.h("4?").a(h.a.m(0,"arg1"))),A.fj(q.$ti.h("4?").a(q.a.m(0,"arg2"))),A.fj(p.$ti.h("4?").a(p.a.m(0,"arg3"))),A.fj(o.$ti.h("4?").a(o.a.m(0,"arg4")))))
break
default:l=A.ck("Unknown math request")
throw A.c(l)}l=i
v.G.self.postMessage(A.o2(A.B(["id",l.$ti.h("4?").a(l.a.m(0,"id")),"result",s],k,j)))}catch(n){r=A.ac(n)
l=v.G.self
h=i
q=h.a.m(0,"id")
l.postMessage(A.o2(A.B(["id",h.$ti.h("4?").a(q),"error",J.b2(r)],k,j)))}},
$S:86}
A.cR.prototype={
b8(a,b,c){if(A.K(A.bs(v.G._symCcallNumSetElem(this.a,a,b,c)))!==0)throw A.c(A.ap("matrix_set","Failed to set element at ("+a+", "+b+")",null))},
cL(a,b){var s=A.I(v.G._symCcallStrGetElem(this.a,a,b))
if(B.a.v(s,"Error"))A.x(A.ap("matrix_get",s,null))
return s},
bU(){var s=A.I(v.G._symCcallStrFromPtr("flutter_symengine_matrix_det",this.a))
if(B.a.v(s,"Error"))A.x(A.ap("matrix_det",s,null))
return s},
aS(){var s=A.K(A.bs(v.G._symCcallPtrFromPtr("flutter_symengine_matrix_inv",this.a)))
if(s===0)throw A.c(A.ap("matrix_inv","Matrix inversion failed",null))
return new A.cR(s,this.b,this.c)},
A(a,b){var s=A.K(A.bs(v.G._symCcallPtrFromPtrPtr("flutter_symengine_matrix_add",this.a,b.a)))
if(s===0)throw A.c(A.ap("matrix_add","Matrix addition failed",null))
return new A.cR(s,this.b,this.c)},
i(a,b){var s=A.K(A.bs(v.G._symCcallPtrFromPtrPtr("flutter_symengine_matrix_mul",this.a,b.a)))
if(s===0)throw A.c(A.ap("matrix_mul","Matrix multiplication failed",null))
return new A.cR(s,this.b,b.c)},
k(a){return A.I(v.G._symCcallStrFromPtr("flutter_symengine_matrix_to_string",this.a))}}
A.cl.prototype={
a6(a){return A.bL("flutter_symengine_simplify",a)},
a7(a,b){return A.ea("flutter_symengine_differentiate",a,b)}}
A.eY.prototype={
k(a){var s=this.c
return"SymbolicMathException: "+(s!=null?"["+s+"] ":"")+this.a+" - "+this.b}}
A.iZ.prototype={};(function aliases(){var s=J.bU.prototype
s.cT=s.k})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0,p=hunkHelpers.installStaticTearOff,o=hunkHelpers.installInstanceTearOff,n=hunkHelpers._instance_1u,m=hunkHelpers._instance_2u
s(J,"ry","p3",87)
r(A,"t6","qH",14)
r(A,"t7","qI",14)
r(A,"t8","qJ",14)
q(A,"nY","t_",1)
r(A,"td","rg",31)
p(A,"cx",1,null,["$3$onError$radix","$1"],["eh",function(a){return A.eh(a,null,null)}],89,0)
o(A.eo.prototype,"gcS",0,3,null,["$3"],["aE"],61,0,0)
r(A,"tg","fQ",90)
r(A,"tI","nG",0)
s(A,"m1","rf",91)
r(A,"tX","bN",10)
var l
n(l=A.cl.prototype,"gcN","a6",5)
m(l,"gdX","a7",32)
r(A,"tG","tQ",6)
r(A,"tF","tP",6)
r(A,"tD","te",6)
r(A,"tH","tY",6)
r(A,"tA","t4",6)
r(A,"tB","t5",6)
r(A,"tC","t9",6)
r(A,"tE","tj",6)
r(A,"o4","tw",6)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.z,null)
q(A.z,[A.l7,J.eA,A.dB,J.d8,A.m,A.d9,A.Q,A.bP,A.a3,A.iC,A.b6,A.dm,A.dI,A.dc,A.dG,A.db,A.aB,A.ah,A.da,A.bI,A.bC,A.j7,A.hX,A.e2,A.hl,A.aP,A.dj,A.b5,A.ca,A.cX,A.co,A.dE,A.fe,A.jn,A.fi,A.b7,A.f7,A.fh,A.k3,A.af,A.bd,A.f5,A.dO,A.b_,A.f3,A.e8,A.dQ,A.f8,A.ba,A.P,A.dS,A.er,A.eu,A.jH,A.ab,A.c5,A.jq,A.dC,A.js,A.T,A.ez,A.a0,A.aD,A.ff,A.bm,A.hW,A.eo,A.U,A.cE,A.az,A.f1,A.Y,A.jp,A.b,A.j,A.h2,A.f4,A.aC,A.jJ,A.jr,A.es,A.jM,A.f,A.G,A.ik,A.k2,A.ax,A.fP,A.a1,A.bK,A.jm,A.jt,A.fb,A.cF,A.E,A.bD,A.bW,A.ao,A.k_,A.b9,A.aq,A.jZ,A.ew,A.cR,A.cl,A.eY])
q(J.eA,[J.eC,J.de,J.a4,J.cI,J.cJ,J.c9,J.bT])
q(J.a4,[J.bU,J.F,A.cd,A.dr])
q(J.bU,[J.eO,J.bH,J.by])
r(J.eB,A.dB)
r(J.hd,J.F)
q(J.c9,[J.cH,J.df])
q(A.m,[A.bY,A.y,A.bz,A.cn,A.c7,A.j6,A.cr,A.f2,A.fd,A.br])
q(A.bY,[A.c3,A.e9])
r(A.dN,A.c3)
r(A.dM,A.e9)
r(A.bx,A.dM)
q(A.Q,[A.c4,A.b4,A.dP])
q(A.bP,[A.eq,A.fK,A.ep,A.eZ,A.kD,A.kF,A.je,A.jd,A.jC,A.jE,A.ho,A.jj,A.jk,A.kH,A.kN,A.kO,A.kz,A.fv,A.fw,A.fy,A.fz,A.fx,A.fG,A.fu,A.fI,A.fH,A.fs,A.ft,A.fA,A.fB,A.fC,A.fD,A.fF,A.fE,A.fq,A.fr,A.fN,A.fR,A.fS,A.ky,A.fY,A.fZ,A.h_,A.fW,A.kR,A.h5,A.h4,A.h6,A.h3,A.h7,A.h8,A.kS,A.kT,A.hh,A.hi,A.hj,A.hk,A.hg,A.hr,A.hs,A.hu,A.hv,A.hw,A.hx,A.hz,A.hA,A.hF,A.hG,A.hH,A.hI,A.hO,A.hP,A.hQ,A.hR,A.hK,A.hL,A.hM,A.hN,A.hJ,A.hD,A.hB,A.jL,A.ke,A.kf,A.kg,A.kn,A.ko,A.kp,A.kq,A.kr,A.ks,A.kt,A.ku,A.kh,A.ki,A.kj,A.kk,A.kl,A.km,A.jN,A.jO,A.jU,A.jV,A.jW,A.jX,A.jY,A.jT,A.jS,A.jP,A.jQ,A.jR,A.ii,A.ih,A.ig,A.i6,A.i7,A.i9,A.i8,A.ic,A.id,A.ia,A.ib,A.il,A.im,A.is,A.it,A.iu,A.iv,A.iA,A.iB,A.iw,A.iy,A.iz,A.iL,A.iE,A.iG,A.iH,A.iI,A.iJ,A.iK,A.k7,A.iN,A.iM,A.iT,A.iS,A.iV,A.iQ,A.iP,A.kb,A.kc,A.kd,A.k9,A.kw,A.kM,A.kV,A.j2,A.j0,A.j_,A.kP,A.kQ,A.kK,A.kI])
q(A.eq,[A.fL,A.kE,A.jD,A.hm,A.hp,A.jI,A.ji,A.fM,A.fO,A.fT,A.fU,A.fV,A.fX,A.ht,A.hV,A.hU,A.hS,A.hT,A.hC,A.jK,A.i_,A.i4,A.i5,A.ij,A.ie,A.io,A.ip,A.ix,A.iO,A.iU,A.iR,A.j3,A.kJ])
q(A.a3,[A.di,A.bF,A.eD,A.f0,A.eR,A.f6,A.dh,A.el,A.b3,A.dH,A.f_,A.cP,A.et])
q(A.y,[A.D,A.at,A.dk,A.O,A.cq,A.dR])
q(A.D,[A.dF,A.t,A.ci])
r(A.c6,A.bz)
q(A.ah,[A.bb,A.c_,A.ct])
q(A.bb,[A.R,A.dX,A.bp,A.dY,A.dZ,A.cY])
q(A.c_,[A.e_,A.cu,A.aR])
q(A.ct,[A.c0,A.e0])
r(A.bQ,A.da)
q(A.bC,[A.cD,A.e1])
q(A.cD,[A.bR,A.bS])
r(A.du,A.bF)
q(A.eZ,[A.eS,A.cC])
r(A.dg,A.b4)
q(A.dr,[A.eG,A.cL])
q(A.cL,[A.dT,A.dV])
r(A.dU,A.dT)
r(A.dp,A.dU)
r(A.dW,A.dV)
r(A.dq,A.dW)
q(A.dp,[A.eH,A.eI])
q(A.dq,[A.eJ,A.eK,A.eL,A.eM,A.eN,A.ds,A.dt])
r(A.e3,A.f6)
q(A.ep,[A.jf,A.jg,A.k4,A.ju,A.jy,A.jx,A.jw,A.jv,A.jB,A.jA,A.jz,A.k1,A.kx,A.jl,A.i0,A.i2,A.i3,A.i1])
r(A.dJ,A.f5)
r(A.fa,A.e8)
r(A.cW,A.dP)
r(A.bJ,A.e1)
r(A.eE,A.dh)
r(A.he,A.er)
r(A.hf,A.eu)
r(A.jG,A.jH)
q(A.b3,[A.dz,A.ey])
q(A.jq,[A.dn,A.bf,A.ch,A.aW,A.be,A.cp])
q(A.E,[A.v,A.an,A.ay,A.a_,A.a7,A.aE])
r(A.iZ,A.eY)
s(A.e9,A.P)
s(A.dT,A.P)
s(A.dU,A.aB)
s(A.dV,A.P)
s(A.dW,A.aB)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{e:"int",h:"double",as:"num",i:"String",w:"bool",aD:"Null",n:"List",z:"Object",aa:"Map",ad:"JSObject"},mangledNames:{},types:["h(h)","~()","w(e)","i(cl)","h(aa<i,h>)","i(i)","h(as)","e(e)","e(e,e)","E(E)","i(E)","w(i)","i(bi)","+ok,x,y(w,h,h)()","~(~())","e(e,E)","f(f)","w(bB)","f(e)","aD(@)","z?(z?)","h?(h,h)","~(@)","~(E)","w(a9)","n<i>(n<i>)","w(n<i>)","+(f,f)(+(f,f),+(f,f))","w(E)","~(z?,z?)","aD()","@(@)","i(i,i)","n<z>(+ok,x,y(w,h,h))","~(+ok,x,y(w,h,h),+ok,x,y(w,h,h))","n<n<z>>(n<+kind,x,y(i,h,h)>)","n<z>(+kind,x,y(i,h,h))","n<h>(+x1,x2,y1,y2(h,h,h,h))","h?(h)","h(e)","E(E,e)","+(f,f)(E,e)","w(n<f>)","w(f)","w(n<h>)","e(e,n<i>)","i(n<h>)","e(a0<i,f>,a0<i,f>)","i(az)","w(i,e)","n<U>(E,e)","n<U>(n<U>,n<U>)","n<h?>(as)","n<U>(n<U>)","h?(i)","w(j)","e(f)","w(+(n<e>,f))","aa<i,f>(aC)","n<e>(i)","i(aa<i,f>)","i(i,i,i)","w(w)","i(bB)","G(f)","G(G,G)","+(G,G)(E,e)","w(G)","a9(f)","f?(i)","h(a9)","h?(f)","n<n<z>>(n<+ok,x,y(w,h,h)>)","i(bK)","i(a0<e,e>)","~(@,@)","i(j)","aD(z,cO)","aD(~())","@(i)","f(E)","a9?(f)","a9?(a9)","e(+mult,root(e,f),+mult,root(e,f))","i(f)","h?(i,aa<i,h>)","aD(a4)","e(@,@)","@(@,i)","e(i{onError:e(i)?,radix:e?})","i(h)","e(E,E)","w(a9,a9)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;":(a,b)=>c=>c instanceof A.R&&a.b(c.a)&&b.b(c.b),"2;condition,expression":(a,b)=>c=>c instanceof A.dX&&a.b(c.a)&&b.b(c.b),"2;error,value":(a,b)=>c=>c instanceof A.bp&&a.b(c.a)&&b.b(c.b),"2;inner,outer":(a,b)=>c=>c instanceof A.dY&&a.b(c.a)&&b.b(c.b),"2;mult,root":(a,b)=>c=>c instanceof A.dZ&&a.b(c.a)&&b.b(c.b),"2;quotient,remainder":(a,b)=>c=>c instanceof A.cY&&a.b(c.a)&&b.b(c.b),"3;cancelled,denominator,numerator":(a,b,c)=>d=>d instanceof A.e_&&a.b(d.a)&&b.b(d.b)&&c.b(d.c),"3;kind,x,y":(a,b,c)=>d=>d instanceof A.cu&&a.b(d.a)&&b.b(d.b)&&c.b(d.c),"3;ok,x,y":(a,b,c)=>d=>d instanceof A.aR&&a.b(d.a)&&b.b(d.b)&&c.b(d.c),"4;x1,x2,y1,y2":a=>b=>b instanceof A.c0&&A.o6(a,b.a),"5;mag,u,v,x,y":a=>b=>b instanceof A.e0&&A.o6(a,b.a)}}
A.r7(v.typeUniverse,JSON.parse('{"by":"bU","eO":"bU","bH":"bU","u7":"cd","a4":{"ad":[]},"eC":{"w":[],"Z":[]},"de":{"Z":[]},"bU":{"a4":[],"ad":[]},"F":{"n":["1"],"a4":[],"y":["1"],"ad":[],"m":["1"]},"eB":{"dB":[]},"hd":{"F":["1"],"n":["1"],"a4":[],"y":["1"],"ad":[],"m":["1"]},"d8":{"V":["1"]},"c9":{"h":[],"as":[],"aH":["as"]},"cH":{"h":[],"e":[],"as":[],"aH":["as"],"Z":[]},"df":{"h":[],"as":[],"aH":["as"],"Z":[]},"bT":{"i":[],"aH":["i"],"hY":[],"Z":[]},"bY":{"m":["2"]},"d9":{"V":["2"]},"c3":{"bY":["1","2"],"m":["2"],"m.E":"2"},"dN":{"c3":["1","2"],"bY":["1","2"],"y":["2"],"m":["2"],"m.E":"2"},"dM":{"P":["2"],"n":["2"],"bY":["1","2"],"y":["2"],"m":["2"]},"bx":{"dM":["1","2"],"P":["2"],"n":["2"],"bY":["1","2"],"y":["2"],"m":["2"],"P.E":"2","m.E":"2"},"c4":{"Q":["3","4"],"aa":["3","4"],"Q.K":"3","Q.V":"4"},"di":{"a3":[]},"y":{"m":["1"]},"D":{"y":["1"],"m":["1"]},"dF":{"D":["1"],"y":["1"],"m":["1"],"m.E":"1","D.E":"1"},"b6":{"V":["1"]},"bz":{"m":["2"],"m.E":"2"},"c6":{"bz":["1","2"],"y":["2"],"m":["2"],"m.E":"2"},"dm":{"V":["2"]},"t":{"D":["2"],"y":["2"],"m":["2"],"m.E":"2","D.E":"2"},"cn":{"m":["1"],"m.E":"1"},"dI":{"V":["1"]},"c7":{"m":["2"],"m.E":"2"},"dc":{"V":["2"]},"j6":{"m":["1"],"m.E":"1"},"dG":{"V":["1"]},"db":{"V":["1"]},"ci":{"D":["1"],"y":["1"],"m":["1"],"m.E":"1","D.E":"1"},"R":{"bb":[],"ah":[]},"dX":{"bb":[],"ah":[]},"bp":{"bb":[],"ah":[]},"dY":{"bb":[],"ah":[]},"dZ":{"bb":[],"ah":[]},"cY":{"bb":[],"ah":[]},"e_":{"c_":[],"ah":[]},"cu":{"c_":[],"ah":[]},"aR":{"c_":[],"ah":[]},"c0":{"ct":[],"ah":[]},"e0":{"ct":[],"ah":[]},"da":{"aa":["1","2"]},"bQ":{"da":["1","2"],"aa":["1","2"]},"cr":{"m":["1"],"m.E":"1"},"bI":{"V":["1"]},"cD":{"bC":["1"],"cj":["1"],"y":["1"],"m":["1"]},"bR":{"cD":["1"],"bC":["1"],"cj":["1"],"y":["1"],"m":["1"]},"bS":{"cD":["1"],"bC":["1"],"cj":["1"],"y":["1"],"m":["1"]},"du":{"bF":[],"a3":[]},"eD":{"a3":[]},"f0":{"a3":[]},"e2":{"cO":[]},"bP":{"c8":[]},"ep":{"c8":[]},"eq":{"c8":[]},"eZ":{"c8":[]},"eS":{"c8":[]},"cC":{"c8":[]},"eR":{"a3":[]},"b4":{"Q":["1","2"],"l9":["1","2"],"aa":["1","2"],"Q.K":"1","Q.V":"2"},"at":{"y":["1"],"m":["1"],"m.E":"1"},"aP":{"V":["1"]},"dk":{"y":["1"],"m":["1"],"m.E":"1"},"dj":{"V":["1"]},"O":{"y":["a0<1,2>"],"m":["a0<1,2>"],"m.E":"a0<1,2>"},"b5":{"V":["a0<1,2>"]},"dg":{"b4":["1","2"],"Q":["1","2"],"l9":["1","2"],"aa":["1","2"],"Q.K":"1","Q.V":"2"},"bb":{"ah":[]},"c_":{"ah":[]},"ct":{"ah":[]},"ca":{"qf":[],"hY":[]},"cX":{"bB":[],"bi":[]},"f2":{"m":["bB"],"m.E":"bB"},"co":{"V":["bB"]},"dE":{"bi":[]},"fd":{"m":["bi"],"m.E":"bi"},"fe":{"V":["bi"]},"cd":{"a4":[],"ad":[],"en":[],"Z":[]},"dr":{"a4":[],"ad":[]},"fi":{"en":[]},"eG":{"a4":[],"l2":[],"ad":[],"Z":[]},"cL":{"aO":["1"],"a4":[],"ad":[]},"dp":{"P":["h"],"n":["h"],"aO":["h"],"a4":[],"y":["h"],"ad":[],"m":["h"],"aB":["h"]},"dq":{"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"]},"eH":{"h0":[],"P":["h"],"n":["h"],"aO":["h"],"a4":[],"y":["h"],"ad":[],"m":["h"],"aB":["h"],"Z":[],"P.E":"h"},"eI":{"h1":[],"P":["h"],"n":["h"],"aO":["h"],"a4":[],"y":["h"],"ad":[],"m":["h"],"aB":["h"],"Z":[],"P.E":"h"},"eJ":{"ha":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"eK":{"hb":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"eL":{"hc":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"eM":{"j9":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"eN":{"ja":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"ds":{"jb":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"dt":{"jc":[],"P":["e"],"n":["e"],"aO":["e"],"a4":[],"y":["e"],"ad":[],"m":["e"],"aB":["e"],"Z":[],"P.E":"e"},"f6":{"a3":[]},"e3":{"bF":[],"a3":[]},"af":{"V":["1"]},"br":{"m":["1"],"m.E":"1"},"bd":{"a3":[]},"dJ":{"f5":["1"]},"b_":{"cG":["1"]},"e8":{"n3":[]},"fa":{"e8":[],"n3":[]},"dP":{"Q":["1","2"],"aa":["1","2"]},"cW":{"dP":["1","2"],"Q":["1","2"],"aa":["1","2"],"Q.K":"1","Q.V":"2"},"cq":{"y":["1"],"m":["1"],"m.E":"1"},"dQ":{"V":["1"]},"bJ":{"bC":["1"],"mq":["1"],"cj":["1"],"y":["1"],"m":["1"]},"ba":{"V":["1"]},"Q":{"aa":["1","2"]},"dR":{"y":["2"],"m":["2"],"m.E":"2"},"dS":{"V":["2"]},"bC":{"cj":["1"],"y":["1"],"m":["1"]},"e1":{"bC":["1"],"cj":["1"],"y":["1"],"m":["1"]},"dh":{"a3":[]},"eE":{"a3":[]},"a9":{"aH":["a9"]},"c5":{"aH":["c5"]},"h":{"as":[],"aH":["as"]},"e":{"as":[],"aH":["as"]},"n":{"y":["1"],"m":["1"]},"as":{"aH":["as"]},"bB":{"bi":[]},"cj":{"y":["1"],"m":["1"]},"i":{"aH":["i"],"hY":[]},"ab":{"a9":[],"aH":["a9"]},"el":{"a3":[]},"bF":{"a3":[]},"b3":{"a3":[]},"dz":{"a3":[]},"ey":{"a3":[]},"dH":{"a3":[]},"f_":{"a3":[]},"cP":{"a3":[]},"et":{"a3":[]},"dC":{"a3":[]},"ez":{"a3":[]},"ff":{"cO":[]},"bm":{"qm":[]},"v":{"E":[]},"an":{"E":[]},"ay":{"E":[]},"a_":{"E":[]},"a7":{"E":[]},"aE":{"E":[]},"hc":{"n":["e"],"y":["e"],"m":["e"]},"jc":{"n":["e"],"y":["e"],"m":["e"]},"jb":{"n":["e"],"y":["e"],"m":["e"]},"ha":{"n":["e"],"y":["e"],"m":["e"]},"j9":{"n":["e"],"y":["e"],"m":["e"]},"hb":{"n":["e"],"y":["e"],"m":["e"]},"ja":{"n":["e"],"y":["e"],"m":["e"]},"h0":{"n":["h"],"y":["h"],"m":["h"]},"h1":{"n":["h"],"y":["h"],"m":["h"]}}'))
A.r6(v.typeUniverse,JSON.parse('{"e9":2,"cL":1,"e1":1,"er":2,"eu":2}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",a:"Error: integration interval leaves the real integrand domain",j:"[A-Za-z_][A-Za-z_0-9]*|(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE][+-]?\\d+)?"}
var t=(function rtii(){var s=A.bM
return{u:s("bd"),Z:s("a9"),dI:s("en"),fd:s("l2"),e8:s("aH<@>"),cm:s("az"),gW:s("bQ<i,h>"),Q:s("bR<i>"),dy:s("c5"),gw:s("y<@>"),C:s("a3"),h4:s("h0"),gN:s("h1"),e:s("c8"),gY:s("j"),R:s("bS<e>"),dQ:s("ha"),an:s("hb"),gj:s("hc"),hf:s("m<@>"),W:s("F<a9>"),J:s("F<az>"),S:s("F<b>"),eu:s("F<n<f>>"),cp:s("F<n<+kind,x,y(i,h,h)>>"),dc:s("F<n<+ok,x,y(w,h,h)>>"),bj:s("F<n<i>>"),gy:s("F<n<h>>"),gG:s("F<a1>"),Y:s("F<aC>"),f:s("F<z>"),k:s("F<G>"),j:s("F<f>"),gq:s("F<+(G,e)>"),ca:s("F<+(f,G)>"),gs:s("F<+(f,f)>"),eJ:s("F<+mult,root(e,f)>"),fn:s("F<+kind,x,y(i,h,h)>"),q:s("F<+ok,x,y(w,h,h)>"),B:s("F<+x1,x2,y1,y2(h,h,h,h)>"),fC:s("F<+mag,u,v,x,y(h,h,h,h,h)>"),s:s("F<i>"),h:s("F<E>"),c:s("F<U>"),d8:s("F<bK>"),f7:s("F<w>"),n:s("F<h>"),gn:s("F<@>"),t:s("F<e>"),en:s("F<h?>"),T:s("de"),m:s("ad"),cj:s("by"),aU:s("aO<@>"),aX:s("a4"),ew:s("n<z>"),bJ:s("n<f>"),fM:s("n<+kind,x,y(i,h,h)>"),el:s("n<+ok,x,y(w,h,h)>"),a:s("n<i>"),dX:s("n<U>"),H:s("n<h>"),_:s("n<@>"),L:s("n<e>"),e2:s("a0<i,f>"),gM:s("a0<e,e>"),d0:s("aa<i,f>"),U:s("aa<i,h>"),P:s("aa<i,e>"),r:s("aa<@,@>"),X:s("aa<aa<i,e>,f>"),dv:s("t<i,i>"),x:s("t<i,e>"),b:s("aD"),K:s("z"),aD:s("G"),G:s("f"),gT:s("ua"),bQ:s("+()"),bv:s("+(n<e>,f)"),cX:s("+mult,root(e,f)"),cT:s("+kind,x,y(i,h,h)"),au:s("+ok,x,y(w,h,h)"),bB:s("+x1,x2,y1,y2(h,h,h,h)"),F:s("bB"),bp:s("ci<i>"),l:s("cO"),N:s("i"),I:s("i(bi)"),dG:s("i(i)"),b5:s("i(cl)"),i:s("E"),eb:s("a_"),w:s("v"),eD:s("an"),dm:s("Z"),eK:s("bF"),h7:s("j9"),ai:s("ja"),go:s("jb"),gc:s("jc"),ak:s("bH"),cc:s("cn<i>"),cl:s("ab"),D:s("b_<@>"),cn:s("U"),hg:s("cW<z?,z?>"),dT:s("bK"),aM:s("br<n<e>>"),dW:s("br<+(n<e>,f)>"),y:s("w"),al:s("w(z)"),aN:s("w(i)"),V:s("h"),z:s("@"),fO:s("@()"),E:s("@(z)"),ag:s("@(z,cO)"),p:s("e"),v:s("e(i)"),eH:s("cG<aD>?"),bX:s("ad?"),O:s("z?"),dk:s("i?"),A:s("i(bi)?"),d:s("dO<@,@>?"),g:s("f8?"),fQ:s("w?"),cD:s("h?"),h6:s("e?"),ck:s("e(i)?"),cg:s("as?"),o:s("as"),aT:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.hz=J.eA.prototype
B.b=J.F.prototype
B.c=J.cH.prototype
B.f=J.c9.prototype
B.a=J.bT.prototype
B.hA=J.by.prototype
B.hB=J.a4.prototype
B.E=A.dt.prototype
B.Y=J.eO.prototype
B.H=J.bH.prototype
B.a5=new A.db(A.bM("db<0&>"))
B.e=new A.ez()
B.J=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.dN=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.dS=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.dO=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.dR=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.dQ=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.dP=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.K=function(hooks) { return hooks; }

B.dT=new A.he()
B.i=new A.iC()
B.k=new A.fa()
B.x=new A.ff()
B.dU=new A.aW(0,"integerArithmetic")
B.L=new A.aW(1,"polynomialIntegration")
B.y=new A.aW(8,"symbolicEvaluation")
B.M=new A.aW(9,"simplification")
B.O=new A.be(0,"none")
B.e0=new A.cF(B.O,null)
B.P=new A.be(1,"incomplete")
B.N=new A.cF(B.P,null)
B.z=new A.be(7,"malformed")
B.e1=new A.cF(B.z,null)
B.e3=new A.be(3,"unknownFunction")
B.e4=new A.be(4,"unsupportedFunction")
B.e6=new A.be(6,"wrongArity")
B.e7=new A.T("Not a rational polynomial",null)
B.e8=new A.T("Complex polynomial power budget",null)
B.Q=new A.T("Complex polynomial degree budget",null)
B.l=new A.T("Polynomial coefficient budget",null)
B.e9=new A.T("Complex sum allocation budget",null)
B.ea=new A.T("Zero complex denominator",null)
B.eb=new A.T("multi-letter name",null)
B.ec=new A.T("Unsupported complex coefficient",null)
B.ed=new A.T("expansion too large",null)
B.ee=new A.T("Complex expression budget",null)
B.ef=new A.T("Unsupported complex exponent",null)
B.eg=new A.T("Principal power budget",null)
B.eh=new A.T("Expression bound",null)
B.R=new A.T("Degree bound",null)
B.ei=new A.T("Not a Gaussian-rational constant",null)
B.ej=new A.T("nesting too deep",null)
B.ek=new A.T("Zero polynomial divisor",null)
B.el=new A.T("Zero complex divisor",null)
B.em=new A.T("Nonconstant source denominator",null)
B.en=new A.T("Polynomial degree budget",null)
B.eo=new A.T("unexpected end",null)
B.ep=new A.T("Unsupported exponent",null)
B.eq=new A.T("expected int",null)
B.S=new A.T("non-constant divisor",null)
B.T=new A.T("coefficient too large",null)
B.er=new A.T("Complex product allocation budget",null)
B.es=new A.T("exponent too large",null)
B.n=new A.T("Complex coefficient budget",null)
B.U=new A.T("missing )",null)
B.et=new A.T("Unknown expression",null)
B.eu=new A.T("Complex polynomial expression budget",null)
B.hC=new A.hf(null)
B.ig=new A.bf(0,"cas")
B.a6=new A.b()
B.a7=new A.b()
B.a8=new A.b()
B.bU=new A.b()
B.ir=s([B.a6,B.a7,B.a8,B.bU],t.S)
B.km=s(["expand","factor","simplify"],t.s)
B.eA=new A.j("solve","solve(equation, variable)")
B.cy=new A.b()
B.cJ=new A.b()
B.cU=new A.b()
B.it=s([B.cy,B.cJ,B.cU],t.S)
B.mc=s(["simplify","factor","solve"],t.s)
B.eB=new A.j("expand","expand(expression)")
B.d4=new A.b()
B.df=new A.b()
B.dr=new A.b()
B.iu=s([B.d4,B.df,B.dr],t.S)
B.kn=s(["expand","factor","subst"],t.s)
B.fC=new A.j("simplify","simplify(expression)")
B.dC=new A.b()
B.a9=new A.b()
B.ak=new A.b()
B.iv=s([B.dC,B.a9,B.ak],t.S)
B.ko=s(["expand","solve","gcd"],t.s)
B.hc=new A.j("factor","factor(expression)")
B.av=new A.b()
B.aG=new A.b()
B.aR=new A.b()
B.iG=s([B.av,B.aG,B.aR],t.S)
B.lw=s(["integrate","limit","subst"],t.s)
B.f_=new A.j("diff","diff(expression, variable)")
B.b1=new A.b()
B.bc=new A.b()
B.bn=new A.b()
B.iH=s([B.b1,B.bc,B.bn],t.S)
B.ke=s(["diff","limit","subst"],t.s)
B.f1=new A.j("integrate","integrate(expression, variable[, lower, upper])")
B.by=new A.b()
B.bJ=new A.b()
B.bV=new A.b()
B.iI=s([B.by,B.bJ,B.bV],t.S)
B.mm=s(["solve","simplify","diff"],t.s)
B.eR=new A.j("subst","subst(expression, variable, value)")
B.c5=new A.b()
B.cg=new A.b()
B.cr=new A.b()
B.iJ=s([B.c5,B.cg,B.cr],t.S)
B.kc=s(["diff","integrate","e_precision"],t.s)
B.f4=new A.j("limit","limit(expression, variable, point)")
B.cs=new A.b()
B.ct=new A.b()
B.cu=new A.b()
B.iK=s([B.cs,B.ct,B.cu],t.S)
B.lD=s(["lcm","factor","isprime"],t.s)
B.ho=new A.j("gcd","gcd(a, b)")
B.cv=new A.b()
B.cw=new A.b()
B.cx=new A.b()
B.iL=s([B.cv,B.cw,B.cx],t.S)
B.kA=s(["gcd","factor","factorint"],t.s)
B.f7=new A.j("lcm","lcm(a, b)")
B.cz=new A.b()
B.cA=new A.b()
B.kD=s([B.cz,B.cA],t.S)
B.mb=s(["polydiv","polyresultant","polydiscriminant","factor"],t.s)
B.fu=new A.j("polygcd","polygcd(p, q)")
B.cB=new A.b()
B.cC=new A.b()
B.kE=s([B.cB,B.cC],t.S)
B.jJ=s(["polygcd","polyresultant","polydiscriminant"],t.s)
B.hq=new A.j("polydiv","polydiv(p, q)")
B.cD=new A.b()
B.cE=new A.b()
B.kF=s([B.cD,B.cE],t.S)
B.m9=s(["polygcd","polydiscriminant"],t.s)
B.eU=new A.j("polyresultant","polyresultant(p, q)")
B.cF=new A.b()
B.cG=new A.b()
B.kQ=s([B.cF,B.cG],t.S)
B.ma=s(["polyresultant","polygcd","solve"],t.s)
B.eM=new A.j("polydiscriminant","polydiscriminant(p)")
B.cH=new A.b()
B.cI=new A.b()
B.cK=new A.b()
B.iM=s([B.cH,B.cI,B.cK],t.S)
B.kp=s(["factor","polygcd","isprime"],t.s)
B.hr=new A.j("polyfactor","polyfactor(p, mod=k)")
B.cL=new A.b()
B.cM=new A.b()
B.l0=s([B.cL,B.cM],t.S)
B.jZ=s(["beta","factorial","zeta"],t.s)
B.h4=new A.j("gamma","gamma(x)")
B.cN=new A.b()
B.cO=new A.b()
B.lb=s([B.cN,B.cO],t.S)
B.ku=s(["gamma","erf"],t.s)
B.hy=new A.j("zeta","zeta(s)")
B.cP=new A.b()
B.cQ=new A.b()
B.lm=s([B.cP,B.cQ],t.S)
B.kw=s(["gamma","zeta"],t.s)
B.eJ=new A.j("erf","erf(x)")
B.cR=new A.b()
B.cS=new A.b()
B.ls=s([B.cR,B.cS],t.S)
B.mw=s(["zeta","gamma"],t.s)
B.h_=new A.j("lambertw","lambertw(x)")
B.cT=new A.b()
B.cV=new A.b()
B.lt=s([B.cT,B.cV],t.S)
B.kv=s(["gamma","factorial"],t.s)
B.h6=new A.j("beta","beta(a, b)")
B.cW=new A.b()
B.cX=new A.b()
B.lu=s([B.cW,B.cX],t.S)
B.jY=s(["bessely","gamma","zeta"],t.s)
B.h7=new A.j("besselj","besselj(n, x)")
B.cY=new A.b()
B.cZ=new A.b()
B.lv=s([B.cY,B.cZ],t.S)
B.jX=s(["besselj","gamma"],t.s)
B.f0=new A.j("bessely","bessely(n, x)")
B.d_=new A.b()
B.d0=new A.b()
B.d1=new A.b()
B.iN=s([B.d_,B.d0,B.d1],t.S)
B.kt=s(["fibonacci","gcd","isprime"],t.s)
B.ew=new A.j("factorial","factorial(n)   or   n!")
B.d2=new A.b()
B.d3=new A.b()
B.d5=new A.b()
B.iw=s([B.d2,B.d3,B.d5],t.S)
B.kq=s(["factorial","gcd","isprime"],t.s)
B.f6=new A.j("fibonacci","fibonacci(n)   or   fib(n)")
B.d6=new A.b()
B.d7=new A.b()
B.kG=s([B.d6,B.d7],t.S)
B.kd=s(["diff","limit","simplify"],t.s)
B.he=new A.j("taylor","taylor(f, x, x0, n)   or   series(f, x, n)")
B.d8=new A.b()
B.d9=new A.b()
B.kH=s([B.d8,B.d9],t.S)
B.mk=s(["solve","expand"],t.s)
B.ff=new A.j("linsolve","linsolve(eq1; eq2; \u2026, x, y, \u2026)   or   solvesys(\u2026)")
B.da=new A.b()
B.db=new A.b()
B.kI=s([B.da,B.db],t.S)
B.ml=s(["solve","integrate","diff"],t.s)
B.eD=new A.j("dsolve","dsolve(a*y'' + b*y' + c*y = q(x))")
B.ih=new A.bf(1,"numberTheory")
B.dc=new A.b()
B.dd=new A.b()
B.de=new A.b()
B.ix=s([B.dc,B.dd,B.de],t.S)
B.lV=s(["nextprime","prevprime","factorint"],t.s)
B.hh=new A.j("isprime","isprime(n)")
B.dg=new A.b()
B.dh=new A.b()
B.kJ=s([B.dg,B.dh],t.S)
B.lB=s(["isprime","prevprime","factorint"],t.s)
B.fM=new A.j("nextprime","nextprime(n)")
B.di=new A.b()
B.dj=new A.b()
B.kK=s([B.di,B.dj],t.S)
B.lz=s(["isprime","nextprime","factorint"],t.s)
B.fV=new A.j("prevprime","prevprime(n)")
B.dk=new A.b()
B.dl=new A.b()
B.dm=new A.b()
B.iy=s([B.dk,B.dl,B.dm],t.S)
B.lA=s(["isprime","nextprime","gcd"],t.s)
B.eG=new A.j("factorint","factorint(n)")
B.dn=new A.b()
B.dp=new A.b()
B.kL=s([B.dn,B.dp],t.S)
B.ks=s(["factorint","totient","gcd"],t.s)
B.fL=new A.j("divisors","divisors(n)")
B.dq=new A.b()
B.ds=new A.b()
B.kM=s([B.dq,B.ds],t.S)
B.kr=s(["factorint","modinv","divisors"],t.s)
B.fv=new A.j("totient","totient(n)")
B.dt=new A.b()
B.du=new A.b()
B.kN=s([B.dt,B.du],t.S)
B.lR=s(["modinv","totient","gcd"],t.s)
B.h2=new A.j("modpow","modpow(a, e, m)")
B.dv=new A.b()
B.dw=new A.b()
B.kO=s([B.dv,B.dw],t.S)
B.lS=s(["modpow","gcd","totient"],t.s)
B.hl=new A.j("modinv","modinv(a, m)")
B.dx=new A.b()
B.dy=new A.b()
B.kP=s([B.dx,B.dy],t.S)
B.ly=s(["isprime","modpow","gcd"],t.s)
B.fA=new A.j("jacobi","jacobi(a, n)")
B.dz=new A.b()
B.dA=new A.b()
B.kR=s([B.dz,B.dA],t.S)
B.k1=s(["convergent","pi_precision","gcd"],t.s)
B.fp=new A.j("cfrac","cfrac(x, n)")
B.dB=new A.b()
B.dD=new A.b()
B.kS=s([B.dB,B.dD],t.S)
B.k0=s(["cfrac","pi_precision"],t.s)
B.f5=new A.j("convergent","convergent(x, k)")
B.ii=new A.bf(2,"precision")
B.dE=new A.b()
B.dF=new A.b()
B.kT=s([B.dE,B.dF],t.S)
B.jI=s(["e_precision","sqrt_precision","eulergamma_precision"],t.s)
B.fk=new A.j("pi_precision","pi(N)")
B.dG=new A.b()
B.dH=new A.b()
B.kU=s([B.dG,B.dH],t.S)
B.m7=s(["pi_precision","sqrt_precision","limit"],t.s)
B.h3=new A.j("e_precision","e(N)")
B.dI=new A.b()
B.dJ=new A.b()
B.kV=s([B.dI,B.dJ],t.S)
B.m6=s(["pi_precision","e_precision","simplify"],t.s)
B.fe=new A.j("sqrt_precision","sqrt(k, N)")
B.dK=new A.b()
B.dL=new A.b()
B.kW=s([B.dK,B.dL],t.S)
B.jK=s(["pi_precision","e_precision","sqrt_precision"],t.s)
B.hm=new A.j("eulergamma_precision","EulerGamma(N)")
B.dM=new A.b()
B.aa=new A.b()
B.kX=s([B.dM,B.aa],t.S)
B.m8=s(["pi_precision","zeta","gamma"],t.s)
B.eT=new A.j("evalf","evalf(expr, N)")
B.ab=new A.b()
B.ac=new A.b()
B.kY=s([B.ab,B.ac],t.S)
B.kj=s(["evalf","pi_precision"],t.s)
B.hn=new A.j("cevalf","cevalf(expr, N)")
B.ij=new A.bf(3,"matrix")
B.ad=new A.b()
B.ae=new A.b()
B.af=new A.b()
B.iz=s([B.ad,B.ae,B.af],t.S)
B.iO=s(["det","inv","transpose","rref","eigenvalues"],t.s)
B.f2=new A.j("matrix_literal","Matrix([[a, b, ...], [c, d, ...], ...])")
B.ag=new A.b()
B.ah=new A.b()
B.ai=new A.b()
B.iA=s([B.ag,B.ah,B.ai],t.S)
B.lx=s(["inv","transpose","rref","matrix_literal"],t.s)
B.f3=new A.j("det","det(Matrix(...))")
B.aj=new A.b()
B.al=new A.b()
B.am=new A.b()
B.iB=s([B.aj,B.al,B.am],t.S)
B.kb=s(["det","rref","transpose","matrix_literal"],t.s)
B.hd=new A.j("inv","inv(Matrix(...))")
B.an=new A.b()
B.ao=new A.b()
B.ap=new A.b()
B.iC=s([B.an,B.ao,B.ap],t.S)
B.k9=s(["det","inv","rref","matrix_literal"],t.s)
B.fn=new A.j("transpose","transpose(Matrix(...))")
B.aq=new A.b()
B.ar=new A.b()
B.as=new A.b()
B.iD=s([B.aq,B.ar,B.as],t.S)
B.ka=s(["det","inv","transpose","matrix_literal"],t.s)
B.hk=new A.j("rref","rref(Matrix(...))")
B.at=new A.b()
B.au=new A.b()
B.aw=new A.b()
B.iE=s([B.at,B.au,B.aw],t.S)
B.k8=s(["det","inv","matrix_literal"],t.s)
B.hw=new A.j("matrix_arithmetic","Matrix(...) + / - / *  Matrix(...)")
B.ax=new A.b()
B.ay=new A.b()
B.az=new A.b()
B.iF=s([B.ax,B.ay,B.az],t.S)
B.jH=s(["eigenvectors","det","inv","matrix_literal"],t.s)
B.fR=new A.j("eigenvalues","eigenvalues(Matrix(...))")
B.aA=new A.b()
B.iQ=s([B.aA],t.S)
B.kg=s(["eigenvalues","det","inv","matrix_literal"],t.s)
B.eC=new A.j("eigenvectors","eigenvectors(Matrix(...))")
B.ik=new A.bf(5,"statistics")
B.aB=new A.b()
B.aC=new A.b()
B.kZ=s([B.aB,B.aC],t.S)
B.m1=s(["one_sample_t","welch_t","linreg"],t.s)
B.fl=new A.j("mean","Descriptive Stats \u2192 Sample mean")
B.aD=new A.b()
B.aE=new A.b()
B.l_=s([B.aD,B.aE],t.S)
B.lO=s(["mean","paired_t","welch_t"],t.s)
B.fs=new A.j("one_sample_t","Tests \u2192 One-sample t")
B.aF=new A.b()
B.aH=new A.b()
B.l1=s([B.aF,B.aH],t.S)
B.m4=s(["paired_t","wilcoxon","anova_1"],t.s)
B.hv=new A.j("welch_t","Tests \u2192 Two-sample t (Welch)")
B.aI=new A.b()
B.aJ=new A.b()
B.l2=s([B.aI,B.aJ],t.S)
B.mv=s(["welch_t","sign_test","wilcoxon"],t.s)
B.fY=new A.j("paired_t","Tests \u2192 Paired t")
B.aK=new A.b()
B.aL=new A.b()
B.l3=s([B.aK,B.aL],t.S)
B.m0=s(["welch_t","chi2_independence","wilcoxon"],t.s)
B.fO=new A.j("anova_1","Tests \u2192 One-way ANOVA")
B.aM=new A.b()
B.aN=new A.b()
B.l4=s([B.aM,B.aN],t.S)
B.mo=s(["chi2_independence","fisher_exact","sign_test"],t.s)
B.eO=new A.j("chi2_goodness","Tests \u2192 \u03c7\xb2 goodness-of-fit")
B.aO=new A.b()
B.aP=new A.b()
B.l5=s([B.aO,B.aP],t.S)
B.is=s(["chi2_goodness","fisher_exact","anova_1"],t.s)
B.eX=new A.j("chi2_independence","Tests \u2192 \u03c7\xb2 test of independence")
B.aQ=new A.b()
B.aS=new A.b()
B.l6=s([B.aQ,B.aS],t.S)
B.lC=s(["chi2_independence","chi2_goodness","sign_test"],t.s)
B.fW=new A.j("fisher_exact","Tests \u2192 Fisher's exact (2\xd72)")
B.aT=new A.b()
B.aU=new A.b()
B.l7=s([B.aT,B.aU],t.S)
B.mu=s(["welch_t","sign_test","anova_1"],t.s)
B.eF=new A.j("wilcoxon","Tests \u2192 Wilcoxon rank-sum")
B.aV=new A.b()
B.aW=new A.b()
B.l8=s([B.aV,B.aW],t.S)
B.m5=s(["paired_t","wilcoxon","fisher_exact"],t.s)
B.hi=new A.j("sign_test","Tests \u2192 Paired sign test")
B.aX=new A.b()
B.aY=new A.b()
B.l9=s([B.aX,B.aY],t.S)
B.lN=s(["mean","one_sample_t","poly_fit","exp_fit"],t.s)
B.h5=new A.j("linreg","Regression \u2192 Linear fit")
B.aZ=new A.b()
B.iR=s([B.aZ],t.S)
B.lG=s(["linreg","exp_fit","mean"],t.s)
B.fT=new A.j("poly_fit","Regression \u2192 Polynomial fit")
B.b_=new A.b()
B.iS=s([B.b_],t.S)
B.lH=s(["linreg","poly_fit","mean"],t.s)
B.eQ=new A.j("exp_fit","Regression \u2192 Exponential fit")
B.b0=new A.b()
B.b2=new A.b()
B.la=s([B.b0,B.b2],t.S)
B.ki=s(["erf","mean"],t.s)
B.eP=new A.j("normal_dist","Distributions \u2192 Normal")
B.b3=new A.b()
B.b4=new A.b()
B.lc=s([B.b3,B.b4],t.S)
B.lZ=s(["normal_dist","mean"],t.s)
B.eZ=new A.j("binomial_dist","Distributions \u2192 Binomial")
B.il=new A.bf(6,"constraints")
B.b5=new A.b()
B.b6=new A.b()
B.ld=s([B.b5,B.b6],t.S)
B.jO=s(["all_different","minimize","maximize"],t.s)
B.hu=new A.j("vars","vars: x, y in 1..9")
B.b7=new A.b()
B.b8=new A.b()
B.le=s([B.b7,B.b8],t.S)
B.mt=s(["vars","no_overlap","cumulative"],t.s)
B.eW=new A.j("all_different","allDifferent(a, b, c, \u2026)")
B.b9=new A.b()
B.ba=new A.b()
B.lf=s([B.b9,B.ba],t.S)
B.k7=s(["cumulative","minimize","all_different"],t.s)
B.fw=new A.j("no_overlap","noOverlap(s1=d1, s2=d2, \u2026)")
B.bb=new A.b()
B.bd=new A.b()
B.lg=s([B.bb,B.bd],t.S)
B.lW=s(["no_overlap","minimize","all_different"],t.s)
B.fG=new A.j("cumulative","cumulative(s1=d1@r1, \u2026; capacity=C)")
B.be=new A.b()
B.bf=new A.b()
B.lh=s([B.be,B.bf],t.S)
B.lM=s(["maximize","vars","no_overlap"],t.s)
B.h0=new A.j("minimize","minimize <linear-expression>")
B.bg=new A.b()
B.bh=new A.b()
B.li=s([B.bg,B.bh],t.S)
B.lP=s(["minimize","vars","all_different"],t.s)
B.fS=new A.j("maximize","maximize <linear-expression>")
B.bi=new A.b()
B.j2=s([B.bi],t.S)
B.jW=s(["at_most","exactly","implies"],t.s)
B.eL=new A.j("at_least","atLeast(k, a=1, b=2, \u2026)")
B.bj=new A.b()
B.jd=s([B.bj],t.S)
B.jV=s(["at_least","exactly","implies"],t.s)
B.fJ=new A.j("at_most","atMost(k, a=1, b=2, \u2026)")
B.bk=new A.b()
B.jo=s([B.bk],t.S)
B.jU=s(["at_least","at_most","implies"],t.s)
B.fX=new A.j("exactly","exactly(k, a=1, b=2, \u2026)")
B.bl=new A.b()
B.jz=s([B.bl],t.S)
B.kk=s(["exactly","at_least","all_different"],t.s)
B.eV=new A.j("implies","implies(a=1, b=2)")
B.bm=new A.b()
B.jB=s([B.bm],t.S)
B.jQ=s(["among","nvalue","all_different"],t.s)
B.f8=new A.j("gcc","gcc(x, y, z; 1=2, 2=1)")
B.bo=new A.b()
B.jC=s([B.bo],t.S)
B.kz=s(["gcc","nvalue"],t.s)
B.hg=new A.j("among","among(x, y, z; values=1,3,5; count=c)")
B.bp=new A.b()
B.jD=s([B.bp],t.S)
B.kx=s(["gcc","among","minimize"],t.s)
B.eI=new A.j("nvalue","nvalue(x, y, z; count=c)")
B.bq=new A.b()
B.jE=s([B.bq],t.S)
B.ky=s(["gcc","no_overlap"],t.s)
B.fz=new A.j("at_most_in_a_row","atMostInARow(x, y, z; value=1; max=2)")
B.br=new A.b()
B.iT=s([B.br],t.S)
B.jP=s(["all_different","table"],t.s)
B.fb=new A.j("value_precedence","valuePrecedence(x, y, z; order=1,2,3)")
B.bs=new A.b()
B.iU=s([B.bs],t.S)
B.jF=s(["element","value_precedence","all_different"],t.s)
B.ht=new A.j("table","table(x, y, z; (1,2,3), (4,5,6))")
B.bt=new A.b()
B.iV=s([B.bt],t.S)
B.mp=s(["table","minimize"],t.s)
B.eN=new A.j("element","element(idx; list=10,20,30; value=v)")
B.bu=new A.b()
B.iW=s([B.bu],t.S)
B.iP=s(["no_overlap","cumulative","all_different"],t.s)
B.h8=new A.j("diff_n","diffN((x1, y1, w1, h1), (x2, y2, w2, h2), \u2026)")
B.bv=new A.b()
B.iX=s([B.bv],t.S)
B.jM=s(["all_different","diff_n","no_overlap"],t.s)
B.hf=new A.j("circuit","circuit(next0, next1, \u2026; labels=A, B, \u2026)")
B.bw=new A.b()
B.iY=s([B.bw],t.S)
B.jN=s(["all_different","minimize","implies"],t.s)
B.fy=new A.j("soft","soft(weight): x = 5")
B.bx=new A.b()
B.iZ=s([B.bx],t.S)
B.jL=s(["all_different","among","gcc"],t.s)
B.fB=new A.j("set_var","set Team from 1..5   \xb7   card / subset / disjoint / contains")
B.bz=new A.b()
B.j_=s([B.bz],t.S)
B.k6=s(["cross","norm","matrix_literal"],t.s)
B.fc=new A.j("dot","dot([a1, a2, \u2026], [b1, b2, \u2026])")
B.bA=new A.b()
B.j0=s([B.bA],t.S)
B.kf=s(["dot","norm","matrix_literal"],t.s)
B.fP=new A.j("cross","cross([a1, a2, a3], [b1, b2, b3])")
B.bB=new A.b()
B.j1=s([B.bB],t.S)
B.ms=s(["unit","dot","matrix_literal"],t.s)
B.ey=new A.j("norm","norm([v1, v2, \u2026])")
B.bC=new A.b()
B.j3=s([B.bC],t.S)
B.lX=s(["norm","dot","matrix_literal"],t.s)
B.fg=new A.j("unit","unit([v1, v2, \u2026])")
B.bD=new A.b()
B.j4=s([B.bD],t.S)
B.lT=s(["modpow","modinv","gcd"],t.s)
B.fm=new A.j("mod","a mod n")
B.bE=new A.b()
B.j5=s([B.bE],t.S)
B.mn=s(["sqrt_precision","evalf"],t.s)
B.h9=new A.j("nth_root","\u207f\u221ax  (n-th root of x)")
B.bF=new A.b()
B.j6=s([B.bF],t.S)
B.k3=s(["cos","tan","asin"],t.s)
B.ha=new A.j("sin","sin(x)")
B.bG=new A.b()
B.j7=s([B.bG],t.S)
B.mf=s(["sin","tan","acos"],t.s)
B.fU=new A.j("cos","cos(x)")
B.bH=new A.b()
B.j8=s([B.bH],t.S)
B.me=s(["sin","cos","atan"],t.s)
B.fo=new A.j("tan","tan(x)")
B.bI=new A.b()
B.j9=s([B.bI],t.S)
B.md=s(["sin","acos","atan"],t.s)
B.h1=new A.j("asin","asin(x)")
B.bK=new A.b()
B.ja=s([B.bK],t.S)
B.k2=s(["cos","asin","atan"],t.s)
B.f9=new A.j("acos","acos(x)")
B.bL=new A.b()
B.jb=s([B.bL],t.S)
B.mq=s(["tan","asin","acos"],t.s)
B.fZ=new A.j("atan","atan(x)")
B.bM=new A.b()
B.jc=s([B.bM],t.S)
B.k5=s(["cosh","tanh","asinh"],t.s)
B.fd=new A.j("sinh","sinh(x)")
B.bN=new A.b()
B.je=s([B.bN],t.S)
B.mi=s(["sinh","tanh","acosh"],t.s)
B.fr=new A.j("cosh","cosh(x)")
B.bO=new A.b()
B.jf=s([B.bO],t.S)
B.mh=s(["sinh","cosh","atanh"],t.s)
B.fK=new A.j("tanh","tanh(x)")
B.bP=new A.b()
B.jg=s([B.bP],t.S)
B.mg=s(["sinh","acosh","atanh"],t.s)
B.fI=new A.j("asinh","asinh(x)")
B.bQ=new A.b()
B.jh=s([B.bQ],t.S)
B.k4=s(["cosh","asinh","atanh"],t.s)
B.fh=new A.j("acosh","acosh(x)")
B.bR=new A.b()
B.ji=s([B.bR],t.S)
B.mr=s(["tanh","asinh","acosh"],t.s)
B.fE=new A.j("atanh","atanh(x)")
B.bS=new A.b()
B.jj=s([B.bS],t.S)
B.kl=s(["exp","log","sqrt"],t.s)
B.ft=new A.j("ln","ln(x)")
B.bT=new A.b()
B.jk=s([B.bT],t.S)
B.lI=s(["ln","exp","sqrt"],t.s)
B.eE=new A.j("log","log(x)")
B.bW=new A.b()
B.jl=s([B.bW],t.S)
B.lJ=s(["ln","log","sinh"],t.s)
B.fx=new A.j("exp","exp(x)")
B.bX=new A.b()
B.jm=s([B.bX],t.S)
B.lY=s(["norm","sqrt","evalf"],t.s)
B.hb=new A.j("abs","abs(x)")
B.bY=new A.b()
B.jn=s([B.bY],t.S)
B.m_=s(["nth_root","ln","abs"],t.s)
B.fi=new A.j("sqrt","sqrt(x)")
B.bZ=new A.b()
B.jp=s([B.bZ],t.S)
B.jG=s(["pi_precision","e_precision","euler_gamma"],t.s)
B.eK=new A.j("pi","\u03c0")
B.c_=new A.b()
B.jq=s([B.c_],t.S)
B.mj=s(["solve","evalf","cevalf"],t.s)
B.fQ=new A.j("imaginary_unit","i")
B.c0=new A.b()
B.jr=s([B.c0],t.S)
B.k_=s(["eulergamma_precision","pi","e_precision"],t.s)
B.ez=new A.j("euler_gamma","\u03b3")
B.c1=new A.b()
B.js=s([B.c1],t.S)
B.lF=s(["limit","integrate"],t.s)
B.fH=new A.j("infinity","\u221e")
B.im=new A.bf(7,"sudoku")
B.c2=new A.b()
B.jt=s([B.c2],t.S)
B.lL=s(["sudoku_x","sudoku_disjoint","sudoku_killer"],t.s)
B.fq=new A.j("sudoku_regular","Sudoku \u2192 Regular preset")
B.c3=new A.b()
B.ju=s([B.c3],t.S)
B.lQ=s(["sudoku_regular","sudoku_disjoint","sudoku_killer"],t.s)
B.eY=new A.j("sudoku_x","Sudoku \u2192 X preset")
B.c4=new A.b()
B.jv=s([B.c4],t.S)
B.iq=s(["sudoku_regular","sudoku_x","sudoku_killer"],t.s)
B.hp=new A.j("sudoku_disjoint","Sudoku \u2192 Disjoint Groups preset")
B.c6=new A.b()
B.jw=s([B.c6],t.S)
B.ip=s(["sudoku_regular","sudoku_x","sudoku_disjoint"],t.s)
B.fj=new A.j("sudoku_killer","Sudoku \u2192 Killer preset")
B.io=new A.bf(9,"logic")
B.c7=new A.b()
B.c8=new A.b()
B.lj=s([B.c7,B.c8],t.S)
B.lU=s(["ne_op","and_op"],t.s)
B.hj=new A.j("eq_op","a == b")
B.c9=new A.b()
B.ca=new A.b()
B.lk=s([B.c9,B.ca],t.S)
B.kh=s(["eq_op"],t.s)
B.ev=new A.j("ne_op","a != b")
B.cb=new A.b()
B.cc=new A.b()
B.ll=s([B.cb,B.cc],t.S)
B.lE=s(["le_op","gt_op","ge_op"],t.s)
B.fD=new A.j("lt_op","a < b")
B.cd=new A.b()
B.ce=new A.b()
B.ln=s([B.cd,B.ce],t.S)
B.lK=s(["lt_op","ge_op"],t.s)
B.fF=new A.j("le_op","a <= b")
B.cf=new A.b()
B.jx=s([B.cf],t.S)
B.kB=s(["ge_op","lt_op"],t.s)
B.eH=new A.j("gt_op","a > b")
B.ch=new A.b()
B.jy=s([B.ch],t.S)
B.kC=s(["gt_op","le_op"],t.s)
B.hs=new A.j("ge_op","a >= b")
B.ci=new A.b()
B.cj=new A.b()
B.lo=s([B.ci,B.cj],t.S)
B.m3=s(["or_op","not_op","xor_op"],t.s)
B.ex=new A.j("and_op","a and b")
B.ck=new A.b()
B.jA=s([B.ck],t.S)
B.jR=s(["and_op","not_op","xor_op"],t.s)
B.hx=new A.j("or_op","a or b")
B.cl=new A.b()
B.cm=new A.b()
B.lp=s([B.cl,B.cm],t.S)
B.jS=s(["and_op","or_op"],t.s)
B.fN=new A.j("not_op","not a")
B.cn=new A.b()
B.co=new A.b()
B.lq=s([B.cn,B.co],t.S)
B.m2=s(["or_op","and_op"],t.s)
B.eS=new A.j("xor_op","a xor b")
B.cp=new A.b()
B.cq=new A.b()
B.lr=s([B.cp,B.cq],t.S)
B.jT=s(["and_op","or_op","eq_op"],t.s)
B.fa=new A.j("if_cond","if(condition, then, else)")
B.V=s([B.eA,B.eB,B.fC,B.hc,B.f_,B.f1,B.eR,B.f4,B.ho,B.f7,B.fu,B.hq,B.eU,B.eM,B.hr,B.h4,B.hy,B.eJ,B.h_,B.h6,B.h7,B.f0,B.ew,B.f6,B.he,B.ff,B.eD,B.hh,B.fM,B.fV,B.eG,B.fL,B.fv,B.h2,B.hl,B.fA,B.fp,B.f5,B.fk,B.h3,B.fe,B.hm,B.eT,B.hn,B.f2,B.f3,B.hd,B.fn,B.hk,B.hw,B.fR,B.eC,B.fl,B.fs,B.hv,B.fY,B.fO,B.eO,B.eX,B.fW,B.eF,B.hi,B.h5,B.fT,B.eQ,B.eP,B.eZ,B.hu,B.eW,B.fw,B.fG,B.h0,B.fS,B.eL,B.fJ,B.fX,B.eV,B.f8,B.hg,B.eI,B.fz,B.fb,B.ht,B.eN,B.h8,B.hf,B.fy,B.fB,B.fc,B.fP,B.ey,B.fg,B.fm,B.h9,B.ha,B.fU,B.fo,B.h1,B.f9,B.fZ,B.fd,B.fr,B.fK,B.fI,B.fh,B.fE,B.ft,B.eE,B.fx,B.hb,B.fi,B.eK,B.fQ,B.ez,B.fH,B.fq,B.eY,B.hp,B.fj,B.hj,B.ev,B.fD,B.fF,B.eH,B.hs,B.ex,B.hx,B.fN,B.eS,B.fa],A.bM("F<j>"))
B.hD=s([0.9999999999998099,676.5203681218851,-1259.1392167224028,771.3234287776531,-176.6150291621406,12.507343278686905,-0.13857109526572012,0.000009984369578019572,15056327351493116e-23],t.n)
B.h=s([],t.j)
B.hH={sin:0,cos:1,tan:2,asin:3,acos:4,atan:5,atan2:6,sinh:7,cosh:8,tanh:9,asinh:10,acosh:11,atanh:12,sec:13,csc:14,cot:15,exp:16,ln:17,log:18,log2:19,log10:20,sqrt:21,cbrt:22,abs:23,sign:24,floor:25,ceiling:26,ceil:27,round:28,min:29,max:30,gamma:31,factorial:32,gcd:33,lcm:34,mod:35,conjugate:36,re:37,im:38}
B.d=new A.bS([1],t.R)
B.B=new A.bS([2],t.R)
B.hR=new A.bS([1,2],t.R)
B.a1=new A.bS([1,2,3,4],t.R)
B.W=new A.bQ(B.hH,[B.d,B.d,B.d,B.d,B.d,B.d,B.B,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.hR,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.d,B.a1,B.a1,B.d,B.d,B.B,B.B,B.B,B.d,B.d,B.d],A.bM("bQ<i,cj<e>>"))
B.hJ={}
B.u=new A.bQ(B.hJ,[],t.gW)
B.X={pi:0,PI:1,e:2,E:3,tau:4}
B.hE=new A.bQ(B.X,[3.141592653589793,3.141592653589793,2.718281828459045,2.718281828459045,6.283185307179586],t.gW)
B.hF=new A.dn(0,"loading")
B.A=new A.dn(1,"ready")
B.F=new A.ch(0,"exact")
B.m=new A.ch(2,"symbolic")
B.Z=new A.ch(3,"unknown")
B.hL=new A.ch(4,"unsupported")
B.G=new A.ch(1,"approximate")
B.e_=new A.aW(7,"numericFallback")
B.o=new A.ax(B.G,B.e_,!1,null)
B.hM=new A.ax(B.m,B.L,!1,null)
B.dV=new A.aW(2,"polynomialExpansion")
B.hN=new A.ax(B.m,B.dV,!1,null)
B.v=new A.ax(B.m,B.y,!1,null)
B.dW=new A.aW(3,"rationalIntegration")
B.hO=new A.ax(B.m,B.dW,!1,null)
B.dY=new A.aW(5,"fundamentalTheorem")
B.a_=new A.ax(B.G,B.dY,!1,null)
B.dX=new A.aW(4,"integrationRules")
B.hP=new A.ax(B.m,B.dX,!1,null)
B.w=new A.ax(B.F,B.y,!1,null)
B.dZ=new A.aW(6,"simpsonIntegration")
B.hQ=new A.ax(B.G,B.dZ,!1,null)
B.hS=new A.bR(B.X,5,t.Q)
B.hK={det:0,trace:1,inv:2,transpose:3,rref:4,eigenvalues:5,eigenvectors:6}
B.a0=new A.bR(B.hK,7,t.Q)
B.hG={ln:0,log:1,log2:2,log10:3}
B.hT=new A.bR(B.hG,4,t.Q)
B.hI={gcd:0,lcm:1,mod:2,floor:3,ceiling:4,ceil:5,round:6,sign:7,abs:8,min:9,max:10,factorial:11}
B.hU=new A.bR(B.hI,12,t.Q)
B.hV=new A.an("I")
B.hW=new A.an("pi")
B.j=new A.bD(B.P,null)
B.e2=new A.be(2,"unbalancedClose")
B.a2=new A.bD(B.e2,null)
B.e5=new A.be(5,"divisionByZero")
B.hX=new A.bD(B.e5,null)
B.p=new A.bD(B.z,null)
B.q=new A.ao("\u221e")
B.hY=new A.ao("\u221e")
B.C=new A.ao("-\u221e")
B.hZ=new A.ao("-\u221e")
B.r=new A.ao("0")
B.a3=new A.ao("0")
B.i_=A.bc("en")
B.i0=A.bc("l2")
B.i1=A.bc("h0")
B.i2=A.bc("h1")
B.i3=A.bc("ha")
B.i4=A.bc("hb")
B.i5=A.bc("hc")
B.i6=A.bc("z")
B.i7=A.bc("j9")
B.i8=A.bc("ja")
B.i9=A.bc("jb")
B.ia=A.bc("jc")
B.I=new A.cp(0,"constant")
B.ib=new A.b9(B.I,0,null)
B.a4=new A.cp(1,"logarithmic")
B.ic=new A.b9(B.a4,1,null)
B.D=new A.cp(3,"exponential")
B.id=new A.b9(B.D,1,null)
B.t=new A.cp(2,"polynomial")
B.ie=new A.cp(4,"superExponential")})();(function staticFields(){$.jF=null
$.aT=A.d([],t.f)
$.mH=null
$.mg=null
$.mf=null
$.o1=null
$.nX=null
$.o8=null
$.kB=null
$.kG=null
$.lX=null
$.k0=A.d([],A.bM("F<n<z>?>"))
$.d_=null
$.eb=null
$.ec=null
$.lQ=!1
$.ak=B.k
$.n5=null
$.n6=null
$.n7=null
$.n8=null
$.ly=A.jo("_lastQuoRemDigits")
$.lz=A.jo("_lastQuoRemUsed")
$.dL=A.jo("_lastRemUsed")
$.lA=A.jo("_lastRem_nsh")
$.ce=A.X(t.N,A.bM("es?"))
$.nH=!1
$.mW=!1})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal,r=hunkHelpers.lazy
s($,"u6","og",()=>A.o0("_$dart_dartClosure"))
s($,"u5","m2",()=>A.o0("_$dart_dartClosure_dartJSInterop"))
s($,"uD","ox",()=>A.d([new J.eB()],A.bM("F<dB>")))
s($,"ue","oh",()=>A.bG(A.j8({
toString:function(){return"$receiver$"}})))
s($,"uf","oi",()=>A.bG(A.j8({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"ug","oj",()=>A.bG(A.j8(null)))
s($,"uh","ok",()=>A.bG(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"uk","on",()=>A.bG(A.j8(void 0)))
s($,"ul","oo",()=>A.bG(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"uj","om",()=>A.bG(A.n1(null)))
s($,"ui","ol",()=>A.bG(function(){try{null.$method$}catch(q){return q.message}}()))
s($,"un","oq",()=>A.bG(A.n1(void 0)))
s($,"um","op",()=>A.bG(function(){try{(void 0).$method$}catch(q){return q.message}}()))
s($,"uo","m3",()=>A.qG())
s($,"uA","ov",()=>A.px(0))
s($,"uv","p",()=>A.dK(0))
s($,"ut","o",()=>A.dK(1))
s($,"uu","bO",()=>A.dK(2))
s($,"ur","m5",()=>$.o().n(0))
s($,"up","m4",()=>A.dK(1e4))
r($,"us","os",()=>A.l("^\\s*([+-]?)((0x[a-f0-9]+)|(\\d+)|([a-z0-9]+))\\s*$",!1))
s($,"uq","or",()=>A.py(8))
s($,"uC","fn",()=>A.ei(B.i6))
s($,"uF","kX",()=>new A.f1(B.hF,A.bM("f1<dn>")))
s($,"u4","of",()=>A.l("\\s*[+\\-]\\s*0(\\.0*)?\\s*\\*?\\s*I\\b",!0))
s($,"u1","oc",()=>A.l("\\s*[+\\-]\\s*[^+\\-]*I[^+\\-]*",!0))
s($,"u3","oe",()=>A.l("\\s+",!0))
s($,"u0","ob",()=>A.l("^[\\+\\-\\*\\s]*$",!0))
s($,"u2","od",()=>A.l("([+\\-]?\\d*\\.?\\d+)",!0))
s($,"uy","d5",()=>A.nc(0))
s($,"ux","kW",()=>A.nc(1))
s($,"uw","ot",()=>A.qP($.J(),$.u()))
s($,"uB","ow",()=>A.B(["sqrt",A.tG(),"cbrt",new A.ke(),"exp",A.tE(),"ln",A.o4(),"log",A.o4(),"log10",new A.kf(),"lg",new A.kg(),"log2",new A.kn(),"abs",new A.ko(),"sin",A.tF(),"cos",A.tD(),"tan",A.tH(),"asin",A.tB(),"acos",A.tA(),"atan",A.tC(),"sinh",new A.kp(),"cosh",new A.kq(),"tanh",new A.kr(),"asinh",new A.ks(),"acosh",new A.kt(),"atanh",new A.ku(),"floor",new A.kh(),"ceil",new A.ki(),"ceiling",new A.kj(),"round",new A.kk(),"trunc",new A.kl(),"sign",new A.km(),"gamma",A.tI()],t.N,A.bM("h(h)")))
s($,"u9","J",()=>A.mJ($.p(),$.o()))
s($,"u8","u",()=>{var q=$.o()
return A.mJ(q,q)})
s($,"ub","d4",()=>A.B(["sin",A.fc(new A.iG(),"\\int \\sin x \\, dx = -\\cos x","Antiderivative of sin"),"cos",A.fc(new A.iH(),"\\int \\cos x \\, dx = \\sin x","Antiderivative of cos"),"exp",A.fc(new A.iI(),"\\int e^x \\, dx = e^x","Antiderivative of exp"),"sinh",A.fc(new A.iJ(),"\\int \\sinh x \\, dx = \\cosh x","Antiderivative of sinh"),"cosh",A.fc(new A.iK(),"\\int \\cosh x \\, dx = \\sinh x","Antiderivative of cosh")],t.N,A.bM("fb")))
s($,"uz","ou",()=>{var q=t.N,p=A.hn(B.W.ga9(),q)
p.aJ(0,B.b.ap(B.V,new A.k7(),q))
return p})
s($,"ud","fm",()=>A.mT($.J()))
s($,"uc","ej",()=>A.mT($.u()))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.cd,SharedArrayBuffer:A.cd,ArrayBufferView:A.dr,DataView:A.eG,Float32Array:A.eH,Float64Array:A.eI,Int16Array:A.eJ,Int32Array:A.eK,Int8Array:A.eL,Uint16Array:A.eM,Uint32Array:A.eN,Uint8ClampedArray:A.ds,CanvasPixelArray:A.ds,Uint8Array:A.dt})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,SharedArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.cL.$nativeSuperclassTag="ArrayBufferView"
A.dT.$nativeSuperclassTag="ArrayBufferView"
A.dU.$nativeSuperclassTag="ArrayBufferView"
A.dp.$nativeSuperclassTag="ArrayBufferView"
A.dV.$nativeSuperclassTag="ArrayBufferView"
A.dW.$nativeSuperclassTag="ArrayBufferView"
A.dq.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$0=function(){return this()}
Function.prototype.$2$0=function(){return this()}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$0=function(){return this()}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.ty
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=math_worker.dart.js.map

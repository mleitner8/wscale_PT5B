TITLE na3
: Na current 
: modified from Jeff Magee. M.Migliore may97
: added sh to account for higher threshold M.Migliore, Apr.2002

NEURON {
	SUFFIX na16mut
	USEION na READ ena WRITE ina
	RANGE  gbar, ar2, thegna, ina_ina
	:GLOBAL vhalfs,sh,tha,qa,Ra,Rb,thi1,thi2,qd,qg,mmin,hmin,q10,Rg,qq,Rd,tq,thinf,qinf,vhalfs,a0s,zetas,gms,smax,vvh,vvs
	RANGE vhalfs,sh,tha,qa,Ra,Rb,thi1,thi2,qd,qg,mmin,hmin,q10,Rg,qq,Rd,tq,thinf,qinf,vhalfs,a0s,zetas,gms,smax,vvh,vvs
}

PARAMETER {
	sh   = 8	(mV)
	gbar = 0.01 :0.1 :0.245989   	(mho/cm2)	
								
	tha  =  -33.5	(mV)		: v 1/2 for act ##TF021424 right shifting #-35 to-25 #left shift -45
	qa   = 7.2	(mV)		: act slope (4.5)		
	Ra   = 0.4	(/ms)		: open (v)		
	Rb   = 0.124 	(/ms)		: close (v)		

	thi1  = -47.5	(mV)		: v 1/2 for inact ##TF021424 right shift #-45	
	thi2  = -47.5 	(mV)		: v 1/2 for inact ##TF021424 right shift #-45	
	qd   = 0.5	(mV)	        : inact tau slope 
	qg   = 1.5      (mV)
	mmin=0.02	
	hmin=0.01			
	q10=2
	Rg   = 0.01 	(/ms)		: inact recov (v) 	
	Rd   = .03 	(/ms)		: inact (v)	
	qq   = 10        (mV)
	tq   = -55      (mV)

	thinf  = -51.5 	(mV)		: inact inf slope ##TF021424 right shift #-55
	qinf  = 7 	(mV)		: inact inf slope 

        vhalfs=-26.5	(mV)		: slow inact. ##TF021424 right shift #-60 
        a0s=0.0003	(ms)		: a0s=b0s
        zetas=12	(1)
        gms=0.2		(1)
        smax=10		(ms)
        vvh=-58		(mV) 
        vvs=2		(mV)
        ar2=1		(1)		: 1=no inact., 0=max inact.
	ena		(mV)	
	Ena = 55	(mV)            : must be explicitly def. in hoc
	celsius
	v 		(mV)
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(pS) = (picosiemens)
	(um) = (micron)
} 

ASSIGNED {
	ina 		(mA/cm2)
    ina_ina  (milliamp/cm2)  :to monitor
	thegna		(mho/cm2)
	minf 		
	hinf 		
	mtau (ms)	
	htau (ms) 	
	sinf (ms)	
	taus (ms)
}
 

STATE { m h s}

BREAKPOINT {
        SOLVE states METHOD cnexp
        thegna = gbar*m*m*m*h*s
	ina = thegna * (v - Ena)
    ina_ina = thegna*(v - Ena)     : define  gbar as pS/um2 instead of mllimho/cm2     :to monitor

} 

INITIAL {
	trates(v,ar2,sh)
	m=minf  
	h=hinf
	s=sinf
}


FUNCTION alpv(v) {
         alpv = 1/(1+exp((v-vvh-sh)/vvs))
}
        
FUNCTION alps(v) {  
  alps = exp(1.e-3*zetas*(v-vhalfs-sh)*9.648e4/(8.315*(273.16+celsius)))
}

FUNCTION bets(v) {
  bets = exp(1.e-3*zetas*gms*(v-vhalfs-sh)*9.648e4/(8.315*(273.16+celsius)))
}

LOCAL mexp, hexp, sexp

DERIVATIVE states {   
        trates(v,ar2,sh)      
        m' = (minf-m)/mtau
        h' = (hinf-h)/htau
        s' = (sinf - s)/taus
}

PROCEDURE trates(vm,a2,sh2) {  
        LOCAL  a, b, c, qt
        qt=q10^((celsius-24)/10)
	a = trap0(vm,tha+sh2,Ra,qa)
	b = trap0(-vm,-tha-sh2,Rb,qa)
	mtau = 1/(a+b)/qt
        if (mtau<mmin) {
		mtau=mmin
		}
	minf = a/(a+b)

	a = trap0(vm,thi1,Rd,qd) : +sh2 raus
	b = trap0(-vm,-thi2,Rg,qg) : - sh2 raus
	htau =  1/(a+b)/qt
        if (htau<hmin) {
		htau=hmin
		}
	hinf = 1/(1+exp((vm-thinf)/qinf)): -sh2 raus
	c=alpv(vm)
        sinf = c+a2*(1-c)
        taus = bets(vm)/(a0s*(1+alps(vm)))
        if (taus<smax) {
		taus=smax
		}
}

FUNCTION trap0(v,th,a,q) {
	if (fabs(v-th) > 1e-6) {
	        trap0 = a * (v - th) / (1 - exp(-(v - th)/q))
	} else {
	        trap0 = a * q
 	}
}	
export const cleanCnpj=v=>String(v||'').replace(/\D/g,'');
export const cleanNf=v=>String(v||'').trim().replace(/^0+(?=\d)/,'');
export async function fetchText(url,opts={},ms=12000){const controller=new AbortController();const timer=setTimeout(()=>controller.abort(),ms);try{const res=await fetch(url,{...opts,signal:controller.signal,headers:{'accept':'text/html,application/xhtml+xml','user-agent':'Preguicinha-Tracker/4.0',...(opts.headers||{})}});const text=await res.text();return {ok:res.ok,status:res.status,text:text.slice(0,350000)}}finally{clearTimeout(timer)}}

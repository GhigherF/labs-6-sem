"use client"

import {Post,Put,Delete,Get} from "@/scripts/2"
export default function Home() {
  return (
    <main>
    <h1>Get:</h1>
    <p id="Get"></p>
<div id="results">
</div>

<button onClick={()=>Get()}>Get</button>

<h1>Post:</h1>
<p id="Post"></p>

<input type="number" id="X"/>
<input type="number" id="Y"/>
<select id="Op">
<option>add</option>
<option>sub</option>
<option>mul</option>
<option>div</option>
</select>
<button onClick={()=>Post()}>POST</button>

<h1>Put:</h1>
<p id="Put"></p>
<input type="number" id="PutX"/>
<input type="number" id="PutY"/>
<select id="PutOp">
<option>add</option>
<option>sub</option>
<option>mul</option>
<option>div</option>
</select>
<button onClick={()=>Put()}>PUT</button>

<h1>Delete:</h1>
<p id="Delete"></p>
<button onClick={()=>Delete()}>DELETE</button>


</main>
  );
}

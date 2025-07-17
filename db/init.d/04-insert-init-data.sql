-- 초기 해커뉴스 감성분석 데이터 삽입
INSERT INTO tech_trends.tech_trends_items (id,item_type,text_content,sentiment_score,sentiment_label,extracted_keywords,author,created_at,score,parent_id,root_story_id) VALUES
	 (44586233,'story','Scale AI cuts 14% of workforce after Meta investment, hiring of founder Wang',-0.296,'negative','ai','itg','2025-07-16 20:32:12.123',1,NULL,0),
	 (44586242,'story','Brave Search API Listed in AWS Marketplace',0.5267,'positive','api','w0ts0n','2025-07-16 20:32:12.133',1,NULL,0),
	 (44586250,'story','AI Founder Became a Billionaire by Building ChatGPT for Doctors',0.0,'neutral','ai','andrewl','2025-07-16 20:32:12.165',1,NULL,0),
	 (44586279,'story','If you are using entra &#x2F; azure Active Directory for your external facing auth , use the copilot as your teacher and also use it to build prototype for your use case that you can use to decide if it is the right product.',0.4019,'positive','azure','gritlin','2025-07-16 20:32:12.196',1,NULL,0),
	 (44565802,'story','In defence of Golang error handling',-0.3182,'negative','golang','ajahso4','2025-07-16 20:32:12.201',3,NULL,0),
	 (44586331,'story','I’ve been thinking a lot about the difference between expertise and value. I&#x27;m someone who just wants to build products. I learn things like TypeScript or React only to the extent that I need to get something working. I don’t dive deep unless my product demands it.<p>But most of the industry seems to reward broad or deep expertise, knowledge of systems, protocols, or architectures, even when it’s not directly tied to delivering user value. This makes me wonder: am I doing it wrong?<p>It feels like we often judge engineers by how much they know, not by what they’ve shipped or how much impact they’ve had. It creates this pressure to keep learning things that might not ever help with what I’m actually trying to build. Has anyone else struggled with this? Is optimizing exclusively for value a valid path long term?<p>Would love to hear how others think about this.',0.9506,'positive','react','grandimam','2025-07-16 20:32:12.248',4,NULL,0),
	 (44586425,'story','This is a simple wrapper library to do embeddings &#x2F;similarity search in a simple way.<p>It&#x27;s open-source.',0.0,'neutral','ai','taishikato','2025-07-16 20:32:12.296',1,NULL,0),
	 (44586469,'story','Trump and the Energy Industry Are Eager to Power AI with Fossil Fuels',0.5574,'positive','ai','josefresco','2025-07-16 20:32:12.305',1,NULL,0),
	 (44586475,'story','<a href="https:&#x2F;&#x2F;debunkit.ai&#x2F;" rel="nofollow">https:&#x2F;&#x2F;debunkit.ai&#x2F;</a>
Step 1: Paste a link or type a fact
Step 2: AI scans and compares data
Step 3: Get a trust rating + explanation',0.5106,'positive','ai','debunkit_ai','2025-07-16 20:32:12.311',1,NULL,0),
	 (44565044,'story','Variadic Generics ideas that won''t work for Rust',0.5719,'positive','rust','PaulHoule','2025-07-16 20:39:56.135',4,NULL,0);
INSERT INTO tech_trends.tech_trends_items (id,item_type,text_content,sentiment_score,sentiment_label,extracted_keywords,author,created_at,score,parent_id,root_story_id) VALUES
	 (44586557,'comment','[delayed]',-0.2263,'negative','ai','theamk','2025-07-16 20:39:56.167',0,44586521,0),
	 (44586521,'story','Manual vs. CNC machining as an analogy for manual vs. AI coding',0.0,'neutral','ai','actinium226','2025-07-16 20:39:56.176',1,NULL,0),
	 (44586530,'story','Metaflow: Build, Manage and Deploy AI/ML Systems',0.0,'neutral','ai','plokker','2025-07-16 20:39:56.184',1,NULL,0),
	 (44586644,'story','Ever asked yourself, &quot;Is there a way to check reviews online?&quot; Well look no further than FakeFind. Try it out, and let me know how it goes.
For those who are interested: https:&#x2F;&#x2F;fakefind.ai',-0.128,'negative','ai','FakeFind_ai','2025-07-16 21:00:13.395',1,NULL,0),
	 (44586725,'story','Extract High-Quality Information with the NuExtract LLM',0.0,'neutral','llm','dcu','2025-07-16 21:01:53.217',1,NULL,0),
	 (44586789,'story','Why AI ops miss the real AI adoption problem',-0.5106,'negative','ai','drewdil','2025-07-16 21:27:48.218',1,NULL,0),
	 (44586867,'story','Hi HN!<p>We&#x27;re launching Maida.AI, an open micro-agents project driven by our passion for fully open-source AI tooling. The idea is to build light-weight &quot;micro-agents&quot; that can be composed into larger pipelines.<p>While hacking on the core codebase we hit a pain-point: moving tensors, embeddings, and control frames over JSON&#x2F;HTTP is slow and chat-oriented. So we drafted a binary-first eXtensible Coordination Protocol (XCP) to handle cross-agent communication efficiently.<p>We just pushed the first spec draft and a proof-of-concept implementation here: <a href="https:&#x2F;&#x2F;github.com&#x2F;maida-ai&#x2F;xcp">https:&#x2F;&#x2F;github.com&#x2F;maida-ai&#x2F;xcp</a><p>We&#x27;d love feedback on:<p><pre><code>    * The spec itself (frame layout, codec negotiation, security).
    * Prior art we might have overlooked.
    * Your war-stories moving large AI payloads over existing protocols.
</code></pre>
Thanks for taking a look—happy to discuss and answer questions!<p>~ Maida.AI team',0.9571,'positive','ai','maida-ai','2025-07-16 21:27:48.287',1,NULL,0),
	 (44586905,'comment','Non-paywall: <a href="https:&#x2F;&#x2F;archive.ph&#x2F;v9UjJ" rel="nofollow">https:&#x2F;&#x2F;archive.ph&#x2F;v9UjJ</a>',0.0,'neutral','bitcoin','alexcos','2025-07-16 21:27:48.303',0,44586897,0),
	 (44586897,'story','Cantor Fitzgerald close to $4B SPAC deal with Bitcoin pioneer(Adam Back)',0.0,'neutral','bitcoin','alexcos','2025-07-16 21:27:48.307',1,NULL,0),
	 (44586927,'story','Context in LLMs and the Blockchain',0.0,'neutral','blockchain','jaypinho','2025-07-16 21:27:48.311',1,NULL,0);
INSERT INTO tech_trends.tech_trends_items (id,item_type,text_content,sentiment_score,sentiment_label,extracted_keywords,author,created_at,score,parent_id,root_story_id) VALUES
	 (44586938,'comment','Rails is a one-person framework. But very few apps are one-person apps forever.<p>I’ve seen the same story unfold dozens of times:<p>One dev builds something useful.
It ships. It grows.
Then it outgrows them.<p>No docs.
No tests.
No plan for what happens next.<p>If that sounds familiar… you’re not alone.',0.7524,'positive','rails','robbyrussell','2025-07-16 21:27:48.323',0,44586937,0),
	 (44587252,'comment','If there was an adapter version, for real old school phones, that would be fun.<p>There are so many real old school styles. [0]<p>[0] <a href="https:&#x2F;&#x2F;www.ebay.com&#x2F;sch&#x2F;i.html?_nkw=vintage+phone&amp;_sacat=0&amp;_from=R40&amp;_trksid=p2334524.m570.l1313&amp;_odkw=vintage+land+line+phone&amp;_osacat=0" rel="nofollow">https:&#x2F;&#x2F;www.ebay.com&#x2F;sch&#x2F;i.html?_nkw=vintage+phone&amp;_sacat=0&amp;...</a><p>[0] <a href="https:&#x2F;&#x2F;www.ebay.com&#x2F;sch&#x2F;i.html?_nkw=scooby+phone&amp;_sacat=0&amp;_from=R40&amp;_trksid=p2334524.m570.l1313&amp;_odkw=vintage+phone&amp;_osacat=0" rel="nofollow">https:&#x2F;&#x2F;www.ebay.com&#x2F;sch&#x2F;i.html?_nkw=scooby+phone&amp;_sacat=0&amp;_...</a>',0.5106,'positive','html','Nevermark','2025-07-16 22:00:23.593',0,44587018,0),
	 (44587229,'comment','Love it!<p>To quote Dennis Duffy - The Beeper King - technology is cyclical!<p><a href="https:&#x2F;&#x2F;youtu.be&#x2F;bzm53FAo_q0?si=GNAiR_fgfL3xHNFX" rel="nofollow">https:&#x2F;&#x2F;youtu.be&#x2F;bzm53FAo_q0?si=GNAiR_fgfL3xHNFX</a>',0.6369,'positive','https','ceocoder','2025-07-16 22:00:23.599',0,44587018,0),
	 (44587045,'story','Mark Cuban: Why AI Will Create More Jobs, Not Fewer',0.2732,'positive','ai','Bluestein','2025-07-16 22:00:23.647',2,NULL,0),
	 (44587158,'comment','There’s an extensive change-log supporting the CCCL 3.0 release on GitHub from 3 hours ago: <a href="https:&#x2F;&#x2F;github.com&#x2F;NVIDIA&#x2F;cccl&#x2F;releases&#x2F;tag&#x2F;v3.0.0">https:&#x2F;&#x2F;github.com&#x2F;NVIDIA&#x2F;cccl&#x2F;releases&#x2F;tag&#x2F;v3.0.0</a>',-0.0516,'negative','github','ashvardanian','2025-07-16 22:00:23.664',0,44587102,0),
	 (44587102,'story','Delivering the Missing Building Blocks for Nvidia CUDA Kernel Fusion in Python',-0.4767,'negative','python','ashvardanian','2025-07-16 22:00:23.670',1,NULL,0),
	 (44587248,'story','I authored and developed an interactive children&#x27;s book about entrepreneurship and money management. The journey started with Twinery, the open-source tool for making interactive fiction, discovered right here on HN. The tool kindled memories of reading CYOA style books when I was a kid, and I thought the format would be awesome for writing a story my kids could follow along, incorporating play money to learn about transactions as they occurred in the story.<p>Twinery is a fantastic tool, and I used it to layout the story map. I really wanted to write the content of the story in Emacs and Org Mode however. Thankfully, Twinery provided the ability to write custom Story Formats that defined how a story was exported. I wrote a Story Format called Twiorg that would export the Twinery file to an Org file and then a Org export backend (ox-twee) to do the reverse. With these tools, I could go back and forth between Emacs and Twinery for authoring the story.<p>The project snowballed and I ended up with the book in digital and physical book formats. The Web Book is created using another Org export backend.<p>Ten Dollar Adventure: <a href="https:&#x2F;&#x2F;tendollaradventure.com" rel="nofollow">https:&#x2F;&#x2F;tendollaradventure.com</a><p>Sample the Web Book (one complete storyline&#x2F;adventure): <a href="https:&#x2F;&#x2F;tendollaradventure.com&#x2F;sample&#x2F;" rel="nofollow">https:&#x2F;&#x2F;tendollaradventure.com&#x2F;sample&#x2F;</a><p>I couldn&#x27;t muster the effort to write a special org export backend for the physical books unfortunately and used a commercial editor to format these.<p>Twiorg: <a href="https:&#x2F;&#x2F;github.com&#x2F;danishec&#x2F;twiorg">https:&#x2F;&#x2F;github.com&#x2F;danishec&#x2F;twiorg</a><p>ox-twee: <a href="https:&#x2F;&#x2F;github.com&#x2F;danishec&#x2F;ox-twee">https:&#x2F;&#x2F;github.com&#x2F;danishec&#x2F;ox-twee</a><p>Previous HN post on writing the transaction logic using an LLM in Emacs: <a href="https:&#x2F;&#x2F;blog.tendollaradventure.com&#x2F;automating-story-logic-with-llms&#x2F;" rel="nofollow">https:&#x2F;&#x2F;blog.tendollaradventure.com&#x2F;automating-story-logic-w...</a><p>Twinery 2: &lt;<a href="https:&#x2F;&#x2F;twinery.org&#x2F;" rel="nofollow">https:&#x2F;&#x2F;twinery.org&#x2F;</a>&gt; and discussion on HN: <a href="https:&#x2F;&#x2F;news.ycombinator.com&#x2F;item?id=32788965">https:&#x2F;&#x2F;news.ycombinator.com&#x2F;item?id=32788965</a>',0.9698,'positive','https','dskhatri','2025-07-16 22:00:23.756',1,NULL,0),
	 (44587366,'comment','Let’s be real: most AI tools give you “intelligence” but leave the actual work (and integration) to you.<p>You end up spending days wiring APIs, defining intents, managing state, and still… your AI can’t even click a simple button.<p>That’s why we built Sista AI. A real-time voice-powered AI agent that runs your app with zero code changes.<p>You add this line of code to your frontend (for example ReactJS):<p><pre><code>   &lt;AiAssistantProvider apiKey=&quot;API\_KEY&quot;&gt; &lt;AiAssistantButton &#x2F;&gt; &lt;&#x2F;AiAssistantProvider&gt;
</code></pre>
That’s it. Now your users can literally talk to your app and it will:<p>Click buttons and links<p>Fill out and submit forms<p>Navigate across screens<p>Answer questions with context<p>Trigger your own custom logic<p>Speak 60+ languages<p>And much more...<p>It reads the DOM. It understands what’s on the screen. It access tools, fetch info from a knowledge base and takes a sequence of action.<p>No training<p>No setup<p>No intent mapping<p>No lag<p>Test the agent live on our website <a href="https:&#x2F;&#x2F;smart.sista.ai&#x2F;" rel="nofollow">https:&#x2F;&#x2F;smart.sista.ai&#x2F;</a><p>To install it visit the docs <a href="https:&#x2F;&#x2F;docs.sista.ai&#x2F;" rel="nofollow">https:&#x2F;&#x2F;docs.sista.ai&#x2F;</a><p>Lastly, you wanna try it on your website without installing it yet! We got you covered with a browser extension.<p>Would love to hear your thoughts.',0.8519,'positive','ai','mahmoudzalt','2025-07-16 22:26:35.319',0,44587365,0),
	 (44587365,'story','New AI agent that clicks, types, and responds – without any code changes',0.0,'neutral','ai','mahmoudzalt','2025-07-16 22:26:35.323',1,NULL,0),
	 (44587388,'comment','<a href="https:&#x2F;&#x2F;archive.ph&#x2F;cMLNo" rel="nofollow">https:&#x2F;&#x2F;archive.ph&#x2F;cMLNo</a>',0.0,'neutral','https','richardatlarge','2025-07-16 22:26:35.328',0,44587381,0);
INSERT INTO tech_trends.tech_trends_items (id,item_type,text_content,sentiment_score,sentiment_label,extracted_keywords,author,created_at,score,parent_id,root_story_id) VALUES
	 (44587423,'story','Could AI slow science? Confronting the production-progress paradox',-0.25,'negative','ai','randomwalker','2025-07-16 22:26:35.349',1,NULL,0);


--초기 사전 데이터 삽입
INSERT INTO tech_trends.tech_dictionary (keyword,category) VALUES
	 ('python','language'),
	 ('javascript','language'), 
	 ('js','language'),
	 ('typescript','language'),
	 ('ts','language'),
	 ('rust','language'),
	 ('go','language'),
	 ('golang','language'),
	 ('java','language'),
	 ('cpp','language'),
	 ('c++','language'),
	 ('kotlin','language'),
	 ('swift','language'),
	 ('php','language'),
	 ('ruby','language'),
	 ('scala','language'),
	 ('clojure','language'),
	 ('haskell','language'),
	 ('dart','language'),
	 ('elm','language'),
	 ('elixir','language'),
	 ('perl','language'),
	 ('r','language'),
	 ('julia','language'),
	 ('react','framework'),
	 ('vue','framework'),
	 ('angular','framework'),
	 ('django','framework'),
	 ('rails','framework'),
	 ('express','framework'),
	 ('spring','framework'),
	 ('laravel','framework'),
	 ('flask','framework'),
	 ('fastapi','framework'),
	 ('nextjs','framework'),
	 ('nuxt','framework'),
	 ('svelte','framework'),
	 ('ember','framework'),
	 ('backbone','framework'),
	 ('jquery','framework'),
	 ('bootstrap','framework'),
	 ('tailwind','framework'),
	 ('mui','framework'),
	 ('chakra','framework');
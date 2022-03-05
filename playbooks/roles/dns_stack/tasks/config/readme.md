## How DNSMasq works

It seems the preferred server is determined by the first query to the server after startup, and then the other servers are not tried again until there is a failure of the preferred server. Full explanation from : https://lists.thekelleys.org.uk/pipermail/dnsmasq-discuss/2009q3/003295.html

The algorithm for determining which server to use goes like this.

In the start state, dnsmasq sends the query to all the servers. When the
first server replies, it becomes the preferred server and dnsmasq moves
into a state where only the preferred server is used. It remains in that
state until one of three conditions occur, when dnsmasq moves back to
the initial state and a query is again sent to all the servers. The
conditions are.

1) A SERVFAIL or REFUSED return code is received.
2) More than 50 queries or 10 seconds have elapsed (version 2.51 only)
3) No reply is received and a client times-out and retries a query.


You will see that the actual server used for any query is quite random.
There's a strong assumption in the design that all the available servers
are equivalent and will give the same answers, but that some may be slow
or unavailable. If different servers know different answers, it's
necessary to direct queries to the correct server with the
server=/domain/<ip> syntax.

It is also worth pointing out that your first statement about
"strict-order" is not quite true. Dnsmasq can't keep trying servers in
order, since, after it has sent the query to the first server, it throws
it away. (Dnsmasq doesn't keep copies of queries for all in-progress
queries, that's one reason it has a low memory footprint). It will move
onto the next server when the client times-out and retries the query,
but typically a client will only time-out and retry once, so it only
makes sense to have two servers with "strict-order" unless the clients
are reconfigured for more retries. That's one reason why "strict-order"
is broken and not recommended. The other is that the DNS protocol has no
way of distinguishing a reply which says "this domain does not exist"
from one which says "I know nothing about this domain". If dnsmasq gets
"no such domain" from the first server it tries, that's a valid answer
which will be passed back to the client, the query will not be tried on
the second server. There do exist patches which change this behaviour,
but they make strict-order even more broken, and have never been added
to the official code-base.
#!/usr/bin/env perl
use strict;
use warnings;
use Net::Kafka::Producer;
use Net::Kafka::Consumer;
use AnyEvent;
use feature 'say';
use IO::Handle;
 
# Produce 1 message into "my_topic"
my $condvar     = AnyEvent->condvar;
my $producer    = Net::Kafka::Producer->new(
    'bootstrap.servers' => '192.163.0.16:9092'
);

# Consume message from "my_topic"
my $consumer    = Net::Kafka::Consumer->new(
    'bootstrap.servers'     => '192.163.0.16:9092',
    'group.id'              => 'my_consumer_group',
    'enable.auto.commit'    => 'true',
);


$producer->produce(
    payload => "hello.pl",
    topic   => "my_topic"
)->then(sub {
    my $delivery_report = shift;
    $condvar->send;
    print "Message successfully delivered with offset " . $delivery_report->{offset} . "\n";
}, sub {
    my $error = shift;
    $condvar->send;
    die "Unable to produce a message: " . $error->{error} . ", code: " . $error->{code};
});
$condvar->recv;
 

STDOUT->autoflush(1);

 
my @args = ( 'perl /usr/src/myapp/hello.pl', 'arg1', 'arg2');
my $execCmd = `perl /usr/src/myapp/hello.pl`;
$consumer->subscribe( [ "my_topic" ] );
while (1) {
    my $msg = $consumer->poll(1000);
    if ($msg) {
        if ( $msg->err ) {
            print "Error: ";
        }
        else {
			my $inputfile = $msg->payload;
			print scalar localtime();
            print " Executing script-> $inputfile \n";
			$|=1;
			sleep(2);
			$execCmd = `perl /usr/src/myapp/$inputfile`;
			# say $execCmd;
			print $execCmd;
			print scalar localtime();
			print " Finished script=> $inputfile \n";
        }
    }
	print "...";
}

# cli-hijacker

## Update

This issue was fixed as of AWS CLI 2.1.7.

I want to thank the AWS Sec team for their fast response on this, the fix was merged the next day and released the day after that. I recommend downloading the most recent version if you are using awscli v2 as it will not work with this PoC.

### Summary

Versions 2.0.36 through 2.1.6 leaked info via the user agent that allowed this attack to operate semi-covertly. The underlying mechanism behind the attack still works, as it did before 2.0.36, but without knowing the command that the user is running before hand it is difficult to abuse. See [Prior to 3.0.36](#prior-to-3.0.36) for more info about how other versions of awscli could potentially be abused.

For reference I wrote this post below some time ago about the general underlying issue, it is still relevant to all versions of awscli/SDK.

https://blog.ryanjarv.sh/2020/10/17/abusing-the-aws-sdk.html


## Running Attacker VM

```
## Private repo
git clone git@github.com:RyanJarv/cli-hijacker.git vagrant/cli-hijacker
vagrant up
vagrant ssh
```

Then in the vm as root:
```
./scripts/setup.sh
./scripts/run.sh
./scripts/monitor_http.sh
```

## Troubleshooting

If you don't see output from the monitor_http.sh script and you've used aws-vault in the past, there's a good chance requests are being routed to 169.254.169.254 on your hosts loopeback interface. aws-vault I believe is supposed to remove this when it shuts down but many times it get's left. Try deleting that address to see if that fixes it.

For MacOS:

```
sudo ifconfig lo0 delete 169.254.169.254
```

For Linux:
```
sudo ip addr delete 169.254.169.254 dev lo0
```

## On Your Host

### Conditions

* Using a computer that uses link-local routing
* You don't have a default profile set 
* Are using awscli 2.0.36 through 2.1.6

### Testing it

You should see behavior like this:
```
% aws s3 ls                                                                     
Unable to locate credentials. You can configure credentials by running "aws configure".
ryan@Jarvs-MacBook-Pro aws_cli_hijacking % aws sts get-caller-identity                                                   
{
    "UserId": "AIDAQWYJ4KRIICCD42BCI",
    "Account": "048875983952",
    "Arn": "arn:aws:iam::048875983952:user/attacker"
}
% aws s3 ls                  
Unable to locate credentials. You can configure credentials by running "aws configure".
ryan@Jarvs-MacBook-Pro aws_cli_hijacking % aws ssm put-parameter --name /mys3cr3t --value sup3rs3cr3t --type SecureString
{
    "Version": 1,
    "Tier": "Standard"
}
% aws s3 ls                                                                     
Unable to locate credentials. You can configure credentials by running "aws configure".
```

You should find the secret 'sup3rs3cr3t' uploaded to the attackers account at /mys3cr3t.

## Why

The idea is that you can sit on the local subnet and wait for someone, who:

* doesn't have a default profile set, and:
* accidentally forget's to target a specific account, while:
* they are running a vulnerable api call, with:
* aws cli 2.0.36 through 2.1.6

With these conditions you can control the account the user run's the api call against.

## Prior to 2.0.36

If aws cli is older then you can do the same thing however it's not as reliable and from the victim's perspective fairly noisy. This is because it was difficult to know what command the user is attempting to run at the point you need to serve the credentials.

What ends up happening in the later case it's easiest to simply respond with the attacker's credentials for every request (or possibly only randomly) and hope it end's up being something useful to you. In any case details of the request, will end up in cloudtrail, and you can gather info that way.

Despite it being difficult to predict the command running I wouldn't rely on simply reverting to pre 2.36 behavior alone. In another PoC I was able to achieve the same thing this one does with the exception of showing a different error message, making this difficult to remain undetected while waiting for the above conditions to be met. This other PoC relied on ARP poisoning the victim, serving expired credentials, scraping SNI, reseting the condition to the client and allowing/disallowing retry attempts based on the scraped SNI. This was a fairly complex approach but a better option may have been to monitor DNS if you are in similar position. In any case it's easy to leak metadata.

## Running The Victim Machine

If you'd rather test this in a VM you can use the [victim](./victim) vagrant configuration. Alternatively this is an example of what happens if the victim doesn't use link local routing but a layer 3 hop upstream does.

### Conditions

* Using a host computer that uses link-local routing

### Running it

```
% cd vagrant
% vagrant up
% vagrant ssh
```

Then in the vm, we can run the same commands shown above and should get the same output:
```
% aws s3 # no creds error
% aws sts get-caller-identity # works
% aws s3 ls # no creds error       
% aws ssm put-parameter --name /mys3cr3t --value sup3rs3cr3t --type SecureString # works
% aws s3 ls # no creds error                                                                     
```

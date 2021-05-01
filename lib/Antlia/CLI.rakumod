use Terminal::Boxer;
use Terminal::ANSIColor;

class Player is export {
    has Str $.name;
    has $.throw is rw;
    has $.score is rw = 0;

    my %ascii-art = (
        rock => %?RESOURCES<rock/2>.slurp,
        paper => %?RESOURCES<paper/2>.slurp,
        scissor => %?RESOURCES<scissor/2>.slurp,
    );

    method throw-art() {
        return %ascii-art{$!throw} ~ "\n$!name ($!score)";
    }
}

my Bool $end-loop = False;
signal(SIGINT).tap({$end-loop = True;});

#| text based Rock paper scissors game
multi sub MAIN(
    Int :$players where * >= 2 = 2, #= Number of players (default: 2)
) is export {
    say "Antlia - text based Rock paper scissors game";
    say "--------------------------------------------\n";

    my Player @players;
    for 1 .. $players {
        push @players, Player.new(name => prompt("[Player $_] Name: ").trim);
    }
    print "\n";

    my %score-against = (
        rock => "scissor",
        paper => "rock",
        scissor => "paper"
    );

    my Int $round = 0;
    loop {
        for @players -> $player {
            $player.throw = <rock scissor paper>.pick[0];
        }

        for @players -> $player {
            for @players -> $player-against {
                $player.score += 1 if $player-against.throw
                                   eq %score-against{$player.throw};
            }
        }

        say "[Round {++$round}]";
        say ss-box(:4col, :20cw, @players.map(*.throw-art));

        last if $end-loop;
    }

    with @players.sort(*.score).reverse -> @players-sorted {
        my @scorecard = <Name Score>;
        for @players-sorted -> $player {
            push @scorecard, $player.name, $player.score.Str;
        }
        say ss-box(:2col, :40cw, @scorecard);
        say colored(@players-sorted[0].name, 'cyan') ~ " wins!";
    }
}

multi sub MAIN(
    Bool :$version #= print version
) is export { say "Antlia v" ~ $?DISTRIBUTION.meta<version>; }

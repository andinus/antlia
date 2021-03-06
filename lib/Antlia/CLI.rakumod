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

#| text based Rock paper scissors game
multi sub MAIN(
    Bool :$autoname, #= Autoname the players
    Int :$rounds, #= Number of rounds (default: Inf)
    Int :$players where * >= 2 = 2, #= Number of players (default: 2)
) is export {
    say "Antlia - text based Rock paper scissors game";
    say "--------------------------------------------\n";

    my Player @players;
    if $autoname {
        push @players, Player.new(name => "Player $_") for 1 .. $players;
    } else {
        push @players, Player.new(name => prompt("[Player $_] Name: ").trim)
                             for 1 .. $players;
        print "\n";
    }

    my %score-against = (
        rock => "scissor",
        paper => "rock",
        scissor => "paper"
    );

    my Int $round = 0;
    my Int $columns = @players.elems < 4 ?? (@players.elems < 3 ?? 2 !! 3)
                       !! (@players.elems %% 4 ?? 4
                           !! (@players.elems %% 3 ?? 3 !! 4));

    my Bool $end-loop = False;
    signal(SIGINT).tap({$end-loop = True;});
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
        say ss-box(col => $columns, :20cw, @players.map(*.throw-art));

        last if $end-loop;
        last if ($round == * with $rounds);
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

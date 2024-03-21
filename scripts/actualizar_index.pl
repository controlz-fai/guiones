#! /usr/bin/env swipl

%% actualizar_index.pl
%% Author: Gimenez, Christian.
%%
%% Copyright (C) 2024 Gimenez, Christian
%%
%% This program is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%
%% Marzo 2024

:- module(actualizar_index, []).

:- initialization(main, main).

:- use_module(library(dcg/basics)).

%! ignorefile(?File: atom) is det.
%
% Basenames a ignorar.
ignorefile('..').
ignorefile('.').
ignorefile('index.html').
ignorefile(A) :-
    atom_concat(_, '-drive.html', A).
ignorefile(A) :-
    atom_concat(_, '~', A).
ignorefile(A) :-
    file_name_extension(_Base, Ext, A),
    Ext \= 'html'.

%! ignorefilename(?Path: atom) is det.
%
% Path comleto a ignorar.
ignorefilename(Path) :-
    file_base_name(Path, Basename),
    ignorefile(Basename).

generar_html(Archivo, Html) :-
    file_base_name(Archivo, Basename),
    file_name_extension(Base, _Ext, Basename),
    format(atom(Html), '<p><a href="~s">~s</a></p>\n', [Archivo, Base]).

generar_listado(Path, Htmls) :-
    expand_file_name(Path, Archivos),
    exclude(ignorefilename, Archivos, Archivos2),
    sort(Archivos2, Archivos3),
    maplist(generar_html, Archivos3, Htmls).

%! aplicar_elt(-Commando: atom, -Arg: atom) is det.
%
% Aplicar el comando dado.
aplicar_elt('files', Path) :-
    generar_listado(Path, Htmls),
    maplist(write, Htmls).
aplicar_elt(_, _) :- !.

%! command(-Command: atom, -Args: atom)//
%
% Regla para reconocer un comando de la forma `#COMMAND ARG`.
command(Command, Args) --> blanks, "#", string_without(` `, CommandC),
                         blanks, string(ArgsC), eol,
                         { atom_codes(Command, CommandC),
                           atom_codes(Args, ArgsC) }.

%! parse_line(-Line: codes) is det
%
% Determinar la acción de la línea actual leída.
%
% Si es un comando, expandirlo.
% 
% Si no imprimir la línea a la salida estándar.
parse_line(Line) :-
    phrase(command(Cmd, Arg), Line, []), !,
    aplicar_elt(Cmd, Arg).
parse_line(Line) :-
    format('~s\n', [Line]).

process_line(Stream) :-
    read_line_to_codes(Stream, Line),
    parse_line(Line).    

%! render_template(+TemplatePath: atom) is det.
%
% Expandir un template ejecutando sus comandos.
render_template(TemplatePath) :-
    open(TemplatePath, read, Stream),

    repeat,
    process_line(Stream),
    at_end_of_stream(Stream), !,

    close(Stream).
    
main(Argv) :-
    argv_options(Argv, [Template], _Options),
    render_template(Template).

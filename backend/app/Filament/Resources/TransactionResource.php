<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TransactionResource\Pages;
use App\Models\Transaction;
use Filament\Actions\ViewAction;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TransactionResource extends Resource
{
    protected static ?string $model = Transaction::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-arrows-right-left';

    protected static ?string $navigationLabel = 'Transactions';

    protected static ?int $navigationSort = 3;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('note')
                    ->label('Description')
                    ->searchable()
                    ->limit(40)
                    ->placeholder('—'),
                TextColumn::make('amount')
                    ->label('Amount')
                    ->formatStateUsing(fn (int $state): string => 'Rp ' . number_format($state, 0, ',', '.'))
                    ->sortable(),
                TextColumn::make('type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'income'   => 'success',
                        'expense'  => 'danger',
                        'transfer' => 'info',
                        default    => 'gray',
                    }),
                TextColumn::make('category.name')
                    ->label('Category')
                    ->placeholder('—'),
                TextColumn::make('wallet.name')
                    ->label('Wallet')
                    ->placeholder('—'),
                TextColumn::make('recorder.name')
                    ->label('Recorded By')
                    ->placeholder('—'),
                TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime('d M Y, H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('type')
                    ->options([
                        'income'   => 'Income',
                        'expense'  => 'Expense',
                        'transfer' => 'Transfer',
                    ]),
                Filter::make('date_range')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('from')
                            ->label('From'),
                        \Filament\Forms\Components\DatePicker::make('until')
                            ->label('Until'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['from'],
                                fn (Builder $q, string $date): Builder => $q->whereDate('created_at', '>=', $date)
                            )
                            ->when(
                                $data['until'],
                                fn (Builder $q, string $date): Builder => $q->whereDate('created_at', '<=', $date)
                            );
                    }),
            ])
            ->recordActions([
                ViewAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTransactions::route('/'),
            'view'  => Pages\ViewTransaction::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }
}
